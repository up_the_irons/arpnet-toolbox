# Base class for a system of extracting / finding information within a body
# of non-empty text
class FinderBase
  def find(body)
    if body.nil?
      raise ArgumentError.new("body is nil")
    end

    if body.to_s.empty?
      raise ArgumentError.new("body is empty")
    end
  end
end
