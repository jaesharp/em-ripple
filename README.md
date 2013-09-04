EM-Ripple
=========
Ripple is a peer-to-peer payment system. EM-Ripple is a client library for the
ripple public websocket API. Build trading bots, interfaces and utilities with it.

Alpha Software
--------------
This is nowhere near complete, tested, or debugged. Most of the functionality used in the
examples is not implemented yet. This may destroy your computer, your network and ruin your
friendships. Don't blame me just yet. Have fun, but be careful before using it with real(tm) money.
Otherwise, no worries.

Usage
-----
After installing the gem 'em-ripple', require 'em-ripple' in your EventMachine program.

Security
--------
All messages to and from your peer are validated.

Examples
--------
Make/Take Liquidity Arbitrage Bot: See examples/arbitrage_bot.rb
