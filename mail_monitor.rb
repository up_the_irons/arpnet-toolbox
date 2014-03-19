require 'mail_reader'

# A basic class that retrieves all messages in a mailbox and yields each
# message to a block; it then repeats this after @sleep_time, ad infinitum, or
# a specified maximum number of iterations.  options is passed onto
# MailReader#go.  See MailReader for how to set up mail retrieval settings.
class MailMonitor < MailReader
  def initialize(sleep_time, options = {}, &settings)
    super(&settings)
    @sleep_time = sleep_time
    @options = options
  end

  def go(iterations = nil)
    i = 0

    while true
      if iterations
        i >= iterations ? break : i += 1
      end

      super(@options)

      sleep @sleep_time
    end
  end
end

