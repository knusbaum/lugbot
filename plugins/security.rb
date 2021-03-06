require 'cinch'
require 'json'
require 'open-uri'
require 'cgi'

class SecurityPlugin
    include Cinch::Plugin

    match /security\s+(\d+)$/

    def execute(m, arg)
        arg = arg.to_i
        unless arg.between?(1, 30)
            m.reply(Format(:red, 'Number of articles must be between 1 and 30.'))
            return
        end

        begin
            uri = URI('http://www.cvedetails.com/json-feed.php')
            uri.query = "numrows=#{arg}&orderby=1"
            JSON.parse(uri.read).each do |item|
                case item['cvss_score'].to_f
                when (0.0..3.9)
                    color = :blue
                when (4.0..6.9)
                    color = :yellow
                when (7.0..10)
                    color = :red
                end
                output = "#{item['cve_id']}: #{CGI.unescapeHTML(item['summary'])} (#{item['url']})"
                m.reply(Format(color, output))
            end
        rescue
            m.reply(Format(:red, 'Could not load CVE list.'))
        end
    end
end
