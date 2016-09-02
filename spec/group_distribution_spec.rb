require './src/group_distribution'

RSpec.describe GroupDistribution do
  it 'counts the group members' do
    data = [
        {:randMultiple => 0, :randGraphJava => 1, :randConf => 2},
        {:randMultiple => 2, :randGraphJava => 1, :randConf => 0},
    ]
    uut = GroupDistribution.new(data)
    counts = uut.counts

    expect(counts).to eq({
        :randMultiple => [1, 0, 1],
        :randGraphJava => [0, 2, 0],
        :randConf => [1, 0, 1]
    })
  end
end
