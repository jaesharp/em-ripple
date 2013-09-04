module EMRipple
  module Version
    MAJOR = '0'
    MINOR = '0'
    PATCH = '1alpha'

    def self.to_standard_version_s
      [MAJOR, MINOR, PATCH].join('.')
    end
  end
end
