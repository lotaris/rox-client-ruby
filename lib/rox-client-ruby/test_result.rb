module RoxClient

  class TestResult
    attr_reader :key, :name, :category, :tags, :tickets, :duration, :message

    def initialize project, options = {}

      @key = options[:key]
      @name = options[:name]

      @category = project.category || options[:category]
      @tags = (wrap(project.tags) + wrap(options[:tags])).compact.collect(&:to_s).uniq
      @tickets = (wrap(project.tickets) + wrap(options[:tickets])).compact.collect(&:to_s).uniq

      @grouped = !!options[:grouped]

      @passed = !!options[:passed]
      @duration = options[:duration]
      @message = options[:message]
    end

    def passed?
      @passed
    end

    def grouped?
      @grouped
    end

    def update options = {}
      @passed &&= !!options[:passed]
      @duration += options[:duration]
      @message = [ @message, options[:message] ].select{ |m| m }.join("\n\n") if options[:message]
    end

    def to_h options = {}
      {
        'k' => @key,
        'p' => @passed,
        'd' => @duration
      }.tap do |h|

        h['m'] = @message if @message

        cache = options[:cache]
        first = !cache || !cache.known?(self)
        stale = !first && cache.stale?(self)
        h['n'] = @name if stale or first
        h['c'] = @category if stale or (first and @category)
        h['g'] = @tags if stale or (first and !@tags.empty?)
        h['t'] = @tickets if stale or (first and !@tickets.empty?)
      end
    end

    private

    def wrap a
      a.kind_of?(Array) ? a : [ a ]
    end
  end
end
