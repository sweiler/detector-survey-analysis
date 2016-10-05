class BoxplotDiagram

  attr_reader :boxplots

  def initialize(boxplots)
    @boxplots = boxplots
  end

  def write_file(filename)
    erb = ERB.new(template)
    erb.def_method(self.class, 'render()')
    res = self.render()
    File.write(filename, res)
  end

  private

  def template
    <<EOT
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg"
	version="1.1" baseProfile="full"
	width="<%= width %>px" height="<%= height %>px" viewBox="0 0 <%= width %> <%= height %>">
  <%= rect(0, 0, width, height, 'white') %>

  <%= y_axis %>

  <% boxplots.each_with_index do |plot, idx| %>
    <%= box(plot, idx) %>
    <%= median(plot, idx) %>
    <%= antennas(plot, idx) %>
    <%= outliers(plot, idx) %>
  <% end %>

</svg>
EOT
  end

  def colors
    %w(#ffaaaa #aaffaa #aaaaff #eeee00)
  end

  def width
    plot_middle_line(@boxplots.length)
  end

  def height
    600
  end

  def min_value
    @boxplots.map {|b| b.min_value }.min
  end

  def max_value
    @boxplots.map {|b| b.max_value }.max
  end

  def lower_bound
    floor_to_ten(min_value)
  end

  def floor_to_ten(v)
    if v < 1
      floor_to_ten(v * 10.0) / 10.0
    elsif v > 10
      floor_to_ten(v / 10.0) * 10.0
    else
      v.floor
    end
  end

  def upper_bound
    tenth_power = Math.log10(lower_bound).floor
    (max_value / (10 ** tenth_power)).ceil * (10 ** tenth_power).to_f
  end

  def transform_value(v)
    factor = (height - margin_top - margin_bottom) / (upper_bound - lower_bound)
    (upper_bound - v) * factor + margin_top
  end

  def margin_top
    40
  end

  def margin_bottom
    40
  end

  def y_axis
    axis_x_coord = 120
    big_lines_width = 30
    small_lines_width = 10

    lower_end = height - margin_bottom
    tmp = line(axis_x_coord, margin_top, axis_x_coord, lower_end) +
        line(axis_x_coord - big_lines_width / 2, margin_top, axis_x_coord + big_lines_width / 2, margin_top) +
        line(axis_x_coord - big_lines_width / 2, lower_end, axis_x_coord + big_lines_width / 2, lower_end) +
        text(axis_x_coord - 60, margin_top + 5, upper_bound.to_s + 's') +
        text(axis_x_coord - 60, lower_end + 5, lower_bound.to_s + 's')

    small_step_size = floor_to_ten((upper_bound - lower_bound) / 5.0).to_f
    v = lower_bound + small_step_size

    until v >= upper_bound

      y = transform_value(v)

      tmp += line(axis_x_coord - small_lines_width / 2, y, axis_x_coord + small_lines_width / 2, y)
      tmp += text(axis_x_coord - 50, y + 4, v.to_s + 's', font_size: 10)

      v += small_step_size
    end

    tmp
  end

  def plot_middle_line(idx)
    170 + idx * 80
  end

  def median(plot, idx)
    x = plot_middle_line(idx)
    y = transform_value(plot.median)
    line(x - 10, y, x + 10, y) +
        text(x + 30, y + 4, plot.median.to_s + 's', font_size: 10)
  end

  def box(plot, idx)
    x = plot_middle_line(idx)
    y1 = transform_value(plot.upper_quartile)
    y2 = transform_value(plot.lower_quartile)

    rect(x - 10, y1, x + 10, y2, colors[idx])
  end

  def antennas(plot, idx)
    x = plot_middle_line(idx)
    y1 = transform_value(plot.upper_antenna)
    y2 = transform_value(plot.upper_quartile)
    y3 = transform_value(plot.lower_quartile)
    y4 = transform_value(plot.lower_antenna)

    line(x, y1, x, y2) +
      line(x - 10, y1, x + 10, y1) +
      line(x, y3, x, y4) +
      line(x - 10, y4, x + 10, y4)

  end

  def outliers(plot, idx)
    x = plot_middle_line(idx)

    plot.outliers.map do |v|
      y = transform_value(v)
      "<circle cx=\"#{x}\" cy=\"#{y}\" r=\"2\" />"
    end.reduce('', :+)

  end

  def line(x1, y1, x2, y2)
    "<line x1=\"#{x1}\" x2=\"#{x2}\" y1=\"#{y1}\" y2=\"#{y2}\" stroke=\"black\" stroke-width=\"2\" />"
  end

  def text(x, y, text, options = {})
    font_size = options[:font_size] || default_font_size
    anchor = options[:anchor] || 'middle'

    "<text x=\"#{x}\" y=\"#{y}\" fill=\"black\" style=\"font-size: #{font_size}px; font-family: Helvetica;\" text-anchor=\"#{anchor}\">#{text}</text>"
  end

  def rect(x1, y1, x2, y2, fill = 'green')
    r_width = (x2 - x1).abs
    r_height = (y2 - y1).abs
    start_x = [x1, x2].min
    start_y = [y1, y2].min
    "<rect x=\"#{start_x}\" y=\"#{start_y}\" width=\"#{r_width}\" height=\"#{r_height}\" fill=\"#{fill}\" />"
  end


  def default_font_size
    18
  end
end