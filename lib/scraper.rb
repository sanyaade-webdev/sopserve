class SportTypes
  def initialize
    @url = "http://livetv.ru/en/allupcoming/"
    @type_query = "//td[@background='http://img.livetv.ru/img/aubg.gif']/../.."
  end

  def decode_response(response)
    if response.encoding != "UTF-8"
      response.force_encoding("ISO-8859-1")
      response.encode("UTF-8")
    end
    response
  end

  def parse(response)
    result = {}
    doc = Hpricot(decode_response(response))
    doc.search(@type_query).each do |element|
      url = url(element)
      name = name(element)
      result[name] = url if not url.nil? and not name.nil?
    end
    result
  end

  def url(element)
    if not element['onclick'].nil?
      element['onclick'].sub("document.location = '", "").sub("';", "")
    end
  end

  def name(element)
    element.at("//span[@class='sltitle']").inner_html
  end

  def get_all
    result = EM::Synchrony.sync EventMachine::HttpRequest.new(@url).aget
    parse(result.response)
  end
end
