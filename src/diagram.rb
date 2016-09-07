require 'erb'

class Diagram

  attr_accessor :groups

  def write_file(filename)
    erb = ERB.new(template)
    erb.def_method(self.class, 'render()')
    res = self.render()
    File.write(filename, res)
  end

  # @return Diagram
  def self.new_yes_no(group_labels, data)
    YesNoDiagram.new(group_labels, data)
  end

  private

  def template
    <<EOT
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg"
	version="1.1" baseProfile="full"
	width="<%= width %>px" height="<%= height %>px" viewBox="0 0 <%= width %> <%= height %>">

  <%= y_axis %>

  <%= line(padding, baseline, width - padding, baseline) %>

  <% groups.each_with_index do |group, idx| %>
    <%= text(group_x_center(idx), baseline + default_font_size, group[:label]) %>
    <% group[:data].each_with_index do |value, i| %>
      <%= rect(bar_start(idx, i), y_value(0), bar_end(idx, i), y_value(value), colors[i]) %>
    <% end %>
  <% end %>

</svg>
EOT
  end

  def colors
    ['green', 'blue', 'red']
  end

  def group_width(idx)
    (bar_width + bar_margin) * groups[idx][:data].length
  end

  def padding
    80
  end

  def baseline
    350
  end

  def group_x_center(idx)
    group_start_x(idx) + group_width(idx) / 2
  end

  def group_start_x(idx)
    padding + group_margin / 2 + (0..idx-1).map { |i| group_width(i) + group_margin }.reduce(0, :+)
  end

  def width
    padding + group_start_x(groups.length)
  end

  def height
    baseline + padding
  end

  def default_font_size
    25
  end

  def bar_width
    50
  end

  def group_margin
    20
  end

  def bar_margin
    10
  end

  def bar_start(group_idx, bar_idx)
    group_start_x(group_idx) + bar_idx * (bar_width + bar_margin)
  end

  def bar_end(group_idx, bar_idx)
    bar_start(group_idx, bar_idx) + bar_width
  end

  def y_value(percentage)
    baseline - percentage * (baseline - padding)
  end

  def y_axis
    steps = 4
    res = line(padding, padding, padding, baseline)
    (0..steps).each do |step|
      y = baseline - step * (baseline - padding) / steps
      res += line(padding - 5, y, padding + 5, y)
      res += text(padding - 45, y + 7, "#{step * 100 / steps} %", 20)
    end
    res
  end

  def line(x1, y1, x2, y2)
    "<line x1=\"#{x1}\" x2=\"#{x2}\" y1=\"#{y1}\" y2=\"#{y2}\" stroke=\"black\" stroke-width=\"3\" />"
  end

  def text(x, y, text, font_size = default_font_size)
    "<text x=\"#{x}\" y=\"#{y}\" fill=\"black\" style=\"font-size: #{font_size}px; font-family: Helvetica;\" text-anchor=\"middle\">#{text}</text>"
  end

  def rect(x1, y1, x2, y2, fill = 'green')
    r_width = x2 - x1
    r_height = y2 - y1
    "<rect x=\"#{x1}\" y=\"#{y2}\" width=\"#{r_width}\" height=\"#{r_height}\" fill=\"#{fill}\" />"
  end
end

class YesNoDiagram < Diagram

  def initialize(group_labels, data)
    self.groups = data.map {|key, value| {:label => key, :data => value}}
  end

end
