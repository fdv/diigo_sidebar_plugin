class DiigoSidebar < Sidebar
  display_name "Diigo"
  description 'Bookmarks from <a href="http://diigo.com">Diigo</a> social bookmarking service'

  setting :feed, nil, :label => 'Diigo Username'
  setting :count, 10, :label => 'Items Limit'
  setting :groupdate,   false, :input_type => :checkbox, :label => 'Group links by day'
  setting :description, false, :input_type => :checkbox, :label => 'Show description'
  setting :desclink,    false, :input_type => :checkbox, :label => 'Allow links in description'

  lifetime 1.hour

  def diigo
    @diigo ||= Diigo.new("http://www.diigo.com/rss/user/" + feed) rescue nil
  end

  def parse_request(contents, params)
    return unless diigo

    if groupdate
      @diigo.days = {}
      @diigo.items.each_with_index do |d,i|
        break if i >= count.to_i
        index = d.date.strftime("%Y-%m-%d").to_sym
        (@diigo.days[index] ||= []) << d
      end
      @diigo.days =
        @diigo.days.sort_by { |d| d.to_s }.reverse.collect do |d|
        {:container => d.last, :date => d.first}
      end
    else
      @diigo.items = @diigo.items.slice(0, count.to_i)
    end
  end
end
