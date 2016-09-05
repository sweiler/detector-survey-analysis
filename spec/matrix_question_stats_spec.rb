require './src/matrix_question_stats'
require './src/survey_structure'
require './src/group_divider'

RSpec.describe MatrixQuestionStats do
  survey_structure = SurveyStructure.new(
      {
          :question_types => {:questionA => :matrixA1A5},
          :sub_questions => {
              :questionA => {
                  :questionAx => 'A3',
                  :questionAy => 'A5',
                  :questionAz => 'A2'
              }
          },
          :random_groups_questions => {
              :randA => [
                  [:questionAx, :questionAy, :questionAz],
                  [:questionBx, :questionBy, :questionBz],
                  [:questionCx, :questionCy, :questionCz]
              ]
          }
      }
  )

  it 'generates correctness percentage stats' do
    data = [
        {:randA => 0, :questionAx => 'A3', :questionAy => 'A2', :questionAz => 'A5'}, # 1/3
        {:randA => 1, :questionBx => 'A3', :questionBy => 'A5', :questionBz => 'A1'}, # 2/3
        {:randA => 1, :questionBx => 'A2', :questionBy => 'A5', :questionBz => 'A1'},  # 1/3
        {:randA => 2, :questionCx => 'A3', :questionCy => 'A5', :questionCz => 'A2'},  # 3/3
    ]
    divided_data = GroupDivider.new(survey_structure).divide(data)

    uut = MatrixQuestionStats.new(survey_structure, divided_data)

    result = uut.correctness
    expected = {
        :questionA => [1.0/3.0, 0.5, 1]
    }

    expect(result).to eq(expected)
  end
end