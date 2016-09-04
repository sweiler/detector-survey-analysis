require './src/group_divider'

RSpec.describe GroupDivider do

  it 'divides listCheck according to randMultiple' do
    data = [
        {:randMultiple => 1, :listCheckControl => 'Y', :listCheck => '', :listCheckC2 => ''},
        {:randMultiple => 0, :listCheckControl => '', :listCheck => 'Y', :listCheckC2 => ''},
        {:randMultiple => 2, :listCheckControl => '', :listCheck => '', :listCheckC2 => 'N'},
    ]
    divided = GroupDivider.divide(data)

    expected_data = [
        { :randMultiple => 1, :listCheck => 'Y' },
        { :randMultiple => 0, :listCheck => 'Y' },
        { :randMultiple => 2, :listCheck => 'N' },
    ]

    expect(divided).to eq(expected_data)
  end

  it 'ignores missing fields' do
    data = [
        {},
        {:randMultiple => 1},
        {:randMultiple => 1, :listCheck => 'Y'}
    ]

    divided = GroupDivider.divide(data)

    expect(divided).to eq(data)
  end

  it 'ignores additional fields' do
    data = [
        {:randMultiple => 1, :listCheckControl => 'Y', :listCheck => '', :listCheckC2 => '', :additional => 3},
        {:randMultiple => 0, :listCheckControl => '', :listCheck => 'Y', :listCheckC2 => '', :additional => 2},
    ]

    divided = GroupDivider.divide(data)

    expected = [
        {:randMultiple => 1, :listCheck => 'Y', :additional => 3},
        {:randMultiple => 0, :listCheck => 'Y', :additional => 2},
    ]

    expect(divided).to eq(expected)
  end

  it 'works with the Conf part' do
    data = [
        {:randConf => 1, :jdbcConfCTime => 10.23, 'jdbcConfC[try]'.to_sym => 'A3'}
    ]

    divided = GroupDivider.divide(data)

    expected = [
        {:randConf => 1, :jdbcConfNTime => 10.23, 'jdbcConfN[try]'.to_sym => 'A3'}
    ]

    expect(divided).to eq(expected)
  end
end