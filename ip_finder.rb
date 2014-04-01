require 'netaddr'

# Find an IP address (either IPv4 or IPv6) trailing a token within a body of
# text.  Uses NetAddr for IP validation.
class IpFinder
  def find(body, token = '@ip')
    super rescue nil
    return nil if body.to_s.empty?

    body.each_line do |line|
      if line =~ /(#{token})\s+([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/i
        return $2 if valid_ip?($2)
      end

      # Very rough IPv6 match, but valid_ip?() below will take care of the
      # rest
      if line =~ /(#{token})\s+([0-9a-fA-F:]+)/i
        return $2 if valid_ip?($2)
      end
    end

    nil
  end

  def valid_ip?(ip)
    begin
      ip_cidr = NetAddr::CIDR.create(ip)

      case ip_cidr.version
      when 4:
      when 6:
      else
        raise ArgumentError("Not an IP version that I know of, declaring invalid")
      end

      true
    rescue
      false
    end
  end
end
