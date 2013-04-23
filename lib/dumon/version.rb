module Dumon

  # Version history.
  VERSION_HISTORY = [
    ['0.2.6',   '2013-04-23', 'BF #13, Failure if no default resolution provided by output'],
    ['0.2.5',   '2013-04-02', 'BF #12, Profile dialog fails if configuration is empty'],
    ['0.2.4',   '2013-03-29', 'New CLI argument: --reset, tested with MRI Ruby 2.0.0'],
    ['0.2.3',   '2013-03-17', 'BF #10: Profile dialog fails unless configuration exists'],
    ['0.2.2',   '2013-03-15', 'Enh #6: Vertical location of outputs'],
    ['0.2.1',   '2013-03-13', 'BF #9: Crash Ruby 1.8.7 because of Dir.home'],
    ['0.2.0',   '2013-03-12', 'Enh #5: Profiles; File based configuration'],
    ['0.1.7',   '2013-02-13', 'Enh #4: About dialog'],
    ['0.1.6',   '2013-02-11', 'BF #3: Crash by rendering popup menu if only one output is there'],
    ['0.1.5',   '2013-02-08', 'Enh #2: Support for primary output'],
    ['0.1.4',   '2013-02-07', 'Enh #1: Starting as daemon'],
    ['0.1.3',   '2013-02-03', 'Changed starting mechanism'],
    ['0.1.2',   '2013-02-01', 'Refactoring: class name optimalization'],
    ['0.1.1',   '2013-01-28', 'Release candidate supporting two output devices'],
    ['0.1.0',   '2013-01-21', 'Initial version on Ruby-1.9.3p374']
  ]

  # Current version.
  VERSION = VERSION_HISTORY[0][0]

  ###
  # Returns the version of Dumon.
  def self.version
    VERSION
  end

end
