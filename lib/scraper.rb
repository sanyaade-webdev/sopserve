module LiveTVScraper
  def decode_response(response)
    if response.encoding != "UTF-8"
      response.force_encoding("ISO-8859-1")
      response.encode("UTF-8")
    end
    HTMLEntities.new.decode(response)
  end

  def full_url(path)
    "http://livetv.ru#{path}"
  end

  def url_to_id(url)
    Base64.encode64(url).strip
  end

  def id_to_url(id)
    Base64.decode64(id).strip
  end
end

class Sport
  include LiveTVScraper

  def initialize(id)
    @url = full_url(id_to_url(id))
    @div_id = "sport" + @url.split("/")[-1]
  end

  # Return all current events: events are returned
  # if they are already occuring or will occur within
  # the leadtime minutes.
  def get_current_events(leadtime)
    get_all_events.find_all { |event|
      event[:time].advance(:minutes => -leadtime) <= DateTime.now
    }
  end

  # Return all upcoming events for this sport
  def get_all_events
    result = EM::Synchrony.sync EventMachine::HttpRequest.new(@url).aget
    parse(result.response)
  end

  private

  def parse(response)
    events = []
    response = decode_response(response)
    doc = Hpricot(fix_markup(response), :fixup_tags => true)
    doc.search("//div[@id='#{@div_id}]//td").each do |element|
      next if not event_cell? element
      events << {
        :id => url_to_id(url(element)),
        :name => name(element),
        :category => category(element),
        :time => time(element)
      }
    end
    events
  end

  def fix_markup(markup)
    markup = markup.gsub(/<\/tr>\s*<\/tr>/, "</tr>")
    markup.gsub(/<\/tr>\s*<td>\s*<tr>/, "</tr><tr>")
  end

  def name(element)
    element.at("//a").inner_html
  end

  def url(element)
    element.at("//a")[:href]
  end

  def category(element)
    category = detail(element).split("\n")[1]
    category[1..-2] if not category.nil?
  end

  def time(element)
    time = detail(element).split("\n")[0]
    parse_time(time) if not time.nil?
  end

  def detail(element)
    element.at("//span[@class='evdesc']").to_plain_text
  end

  def parse_time(time)
    day, month, at, time = time.split
    Chronic.parse "#{month} #{day} at #{time}"
  end

  def event_cell?(element)
    element[:id] and element[:id].match(/^event/)
  end
end

class SportTypes
  include LiveTVScraper

  def initialize
    @url = full_url("/en/allupcoming/")
  end

  # Return a list of all sport types.
  def get_all
    result = EM::Synchrony.sync EventMachine::HttpRequest.new(@url).aget
    parse(result.response)
  end

  private

  def parse(response)
    result = []
    doc = Hpricot(decode_response(response))
    query = "//td[@background='http://img.livetv.ru/img/aubg.gif']/../.."
    doc.search(query).each do |element|
      url = url(element)
      name = name(element)
      next if url.nil? or name.nil?
      result << {
        :id => url_to_id(url),
        :name => name
      }
    end
    result
  end

  def url(element)
    if not element[:onclick].nil?
      element[:onclick].sub("document.location = '", "").sub("';", "")
    end
  end

  def name(element)
    element.at("//span[@class='sltitle']").inner_html
  end
end
