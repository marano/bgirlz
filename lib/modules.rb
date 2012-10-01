module LinkOpener
  def content_from_link(link)
    uri = URI.parse(link)
    http = Net::HTTP.new(uri.host, uri.port) 

    if link =~ /https:/
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    request = Net::HTTP::Get.new(uri.request_uri)

    response = http.request(request)

    if response.code == '301'
      new_location = response.header['Location']
      return content_from_link(new_location)
    else
      return response.body
    end
  end
end
