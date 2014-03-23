class StoryCacher
  cattr_accessor :DIFFBOT_API_KEY

  # this needs to be overridden in config/initializers/production.rb
  @@DIFFBOT_API_KEY = nil

  DIFFBOT_API_URL = "http://www.diffbot.com/api/article"

  def self.get_story_text(url)
    if !@@DIFFBOT_API_KEY
      return
    end

    # XXX: diffbot tries to read pdfs as text, so disable for now
    if url.to_s.match(/\.pdf$/i)
      return nil
    end

    db_url = "#{DIFFBOT_API_URL}?token=#{@@DIFFBOT_API_KEY}&url=" <<
      CGI.escape(url)

    begin
      s = Sponge.new
      # we're not doing this interactively, so take a while
      s.timeout = 45
      res = s.fetch(db_url)
      if res.present?
        j = JSON.parse(res)

        return j["text"]
      end

    rescue => e
      Rails.logger.error "error fetching #{db_url}: #{e.message}"
    end

    nil
  end
end
