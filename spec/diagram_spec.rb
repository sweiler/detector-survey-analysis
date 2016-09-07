require './src/diagram'

RSpec.describe Diagram do

  it 'creates a diagram for grouped y/n questions' do
    filename = 'example_diagram.svg'
    data = {
        :questionA => [0.25, 0.5, 0.75],
        :questionB => [0.8, 0.4, 0.2]
    }

    group_labels = ['Group A', 'Group B', 'Group C']

    diagram = Diagram.new_yes_no(group_labels, data)
    diagram.write_file(filename)

    expect(File).to exist(filename)
    # File.unlink(filename)
  end

end