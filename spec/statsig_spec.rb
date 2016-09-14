require './src/statsig'

RSpec.describe Statsig do
  it 'computes the significance for a hypothesis groupA > groupB' do
    data = [{:true => 1, :false => 2}, {:true => 9, :false => 1}]
    generated_data = []
    data.each_with_index do |hsh, idx|
      hsh[:true].times { generated_data.push({:group => idx, :val => true}) }
      hsh[:false].times { generated_data.push({:group => idx, :val => false}) }
    end
    expect(generated_data.length).to eq(13)

    result = Statsig.significance_a_greater_b(generated_data, :group, 1, 0, :val)
    expect(result).to be_between(0.0001, 0.3)
  end
end