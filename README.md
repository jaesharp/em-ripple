EM-Ripple
=========
Ripple is a peer-to-peer payment system. EM-Ripple is a client library for the
ripple public websocket API. Build trading bots, interfaces and utilities with it.

Usage
-----
After installing the gem 'em-ripple', require 'em-ripple' in your EventMachine program.
See the generated documentation (if you're using the source repository, run `rake doc` to
generate documentation) for callbacks.

Security
--------
All messages to and from your peer are validated.

Examples
--------
Make/Take Liquidity Arbitrage Bot:
```
require 'eventmachine'
require 'em-ripple'

EM.run do

  # the dry_run option means that the client creates no new transactions
  ripple_client = Ripple::Client.new(host: 's1.ripple.net', port: 443, dry_run: true)

  ##
  # Setup wallets
  ##

  # use separate wallets because the ripple network will ripple our IOUs if we trust both issuers in a single
  # wallet

  xrp_reserve_wallet = Ripple::Wallet.new(
    name: 'quokka',
    password: 'corgegrault9000(yah, nah. This isn't a real password mates.)'
    blobvault: 'https://blobvault.payward.com'
  )

  hot_bitstamp_wallet = Ripple::Wallet.new(
    name: 'boondaburra',
    password: 'foobar9000(yah, nah. This isn't a real password mates.)',
    blobvault: 'https://blobvault.payward.com'
  )

  hot_we_exchange_wallet = Ripple::Wallet.new(
    name: 'kangaroo',
    password: 'bazquux9000(yah, nah. This isn't a real password mates.)',
    blobvault: 'https://blobvault.payward.com'
  )

  ##
  # Setup Issuer Account References
  ##

  bitstamp = Ripple::Account.new(address: 'rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B')

  # WARNING: WeExchange address is not verified (it also has a typo, because I know you probably won't read this)
  we_exchange = Ripple::Account.new(address: 'r9vbV3EHvXWjSkeQ6CAcYVPGeq7TuiXY2dX')

  ##
  # Configure the Trade::Engine
  ##

  trade_engine = Ripple::Trade::Engine.new(
    client: ripple_client, # this trade engine will execute all trades through the given client[s]
    issuers: {
      :bitstamp => bitstamp,
      :we_exchange => we_exchange
    },
    active_trading_wallets: {
      :bitstamp => hot_bitstamp_wallet,
      :we_exchange => hot_we_exchange_wallet
    },
    xrp_reserve_wallet: xrp_reserve_wallet,
    # TradeEngine uses cartesian product and ripples through XRP implicitly when declaring interest in a currency
    # orderbook. For instance, here we look at USDbitstamp/USDwe_exchange, USDbitstamp/BTCbitstamp, USDwe_exchange/BTCbitstamp,
    # USDbitstamp/BTCwe_exchange, USDwe_exchange/BTCwe_exchange, BTCbitstamp/BTCwe_exchange, USDBitstamp/XRP, USDwe_exchange/XRP,
    # BTCbitstamp/XRP, BTCwe_exchange/XRP. Not all of these direct exchanges will exist, but we will try to get data for them anyway.
    currencies_of_interest: [:usd, :btc, :xrp]
  )

  ##
  # Do things we must do before we begin our automated trading session
  ##

  trade_engine.before_trading_starts do

    ##
    # Ensure our wallets are set up to trade with our issuers
    ##

    ensure_bitstamp_trusted_by_wallet bitstamp_wallet do
      with_trust_line 10_000, :usd
      with_trust_line 1_000, :btc
    end

    ensure_we_exchange_trusted_by_wallet we_exchange_wallet do
      with_trust_line 10_000, :usd
      with_trust_line 1_000, :btc
    end

  end

  ##
  # Define our Trading Strategies for Arbitrage
  ##
  take_liquidity_strategy = Ripple::Trade::Strategy(
    trade_engine: trade_engine
  ) do

    # If there is an ordering of exchanges such that cross-exchange spread is a positive number
    # (best bid has exceeded best ask on a cross exchange basis). We make money by selling our
    # IOUs on the exchange which pays more for them (the exchange with the higher best ask) and
    # by buying them again on the exchange which asks for less for them (the exchange with the lower best bid)
    when_cross_exchange_spread_becomes_positive do |best_bid, best_ask|
      underpriced_exchange = best_bid.exchange
      overpriced_exchange = best_ask.exchange

      trade_route = Trade::CommonActions::Exchange.compute_order_to_equalize_cross_exchange_price(from: underpriced_exchange, to: overpriced_exchange, via: trade_engine)
      risk_analysis = Trade::CommonActions::RiskAnalysisSuite.evaluate(route: trade_route, via: trade_engine)

      execute(trade_route) if (trade_route.profitable? && risk_analysis.acceptable?)
    end

  end

  make_liquidity_strategy = Ripple::Trade::Strategy(
    trade_engine: trade_engine
  ) do

    when_cross_exchange_spread_becomes_negative do |best_bid, best_ask|
      underpriced_exchange = best_ask.exchange
      overpriced_exchange = best_bid.exchange

      trade_route = Trade::CommonAction::Exchange.compute_order_to_equalize_cross_exchange_price(from: underpriced_exchange, to: overpriced_exchange, via: trade_engine)
      risk_analysis = Trade::CommonActions::RiskAnalysisSuite.evaluate(route: trade_route, via: trade_engine)

      execute(trade_route) if (trade_route.profitable? && risk_analysis.acceptable?)
    end

  end

  ##
  # Maintain Wallet Balances when XRP reserves are low in Hot Wallets
  ##
  hot_bitstamp_wallet.when_balance_falls_below(500, :xrp) do
    xrp_reserve_wallet.transfer(to: hot_bitstamp_wallet, amount: 500, currency: :xrp)
  end
  hot_we_exchange_wallet.when_balance_falls_below(500, :xrp) do
    xrp_reserve_wallet.transfer(to: hot_we_exchange_wallet, amount: 500, currency: :xrp)
  end

  ##
  # Begin trading session, but only for logging
  ##
  trade_engine.start_trading!

end
```
