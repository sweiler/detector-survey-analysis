require './src/group_distribution'
require './src/survey_structure'

RSpec.describe GroupDistribution do
  it 'counts the group members' do
    survey_structure = {
        :random_groups_questions => {
            :randMultiple => [
                [], [], []
            ],
            :randGraphJava => [
                [], [], []
            ],
            :randConf => [
                [], [], []
            ]
        }
    }


    data = [
        {:randMultiple => 0, :randGraphJava => 1, :randConf => 2},
        {:randMultiple => 2, :randGraphJava => 1, :randConf => 0},
    ]
    uut = GroupDistribution.new(SurveyStructure.new(survey_structure), data)
    counts = uut.counts

    expect(counts).to eq({
        :randMultiple => [1, 0, 1],
        :randGraphJava => [0, 2, 0],
        :randConf => [1, 0, 1]
    })
  end
end
