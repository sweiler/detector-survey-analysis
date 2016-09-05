class MatrixQuestionStats
  def initialize(survey_structure, data)
    @survey_structure = survey_structure
    @data = data
  end

  def correctness
    questions = @survey_structure.questions_with_type(:matrixA1A5)
    hashes = questions.map do |question_id|

      sub_questions = @survey_structure.sub_questions(question_id)
      question_grouping_id = @survey_structure.grouping_for_question(sub_questions.keys[0])
      max_grouping_value = @survey_structure.random_groups_max_value[question_grouping_id]

      correct_per_row = @data.map do |row|
        correct_sub_questions = sub_questions.select do |question_id, expected_result|
          row[question_id] == expected_result
        end
        [row[question_grouping_id], (0.0 + correct_sub_questions.length) / sub_questions.length]
      end

      zeros_arr = (0..max_grouping_value).map {|_| [0.0, 0]}
      sum_per_group = correct_per_row.reduce(zeros_arr) do |memo, arr|
        group = arr[0]
        correct_count = arr[1]
        memo[group][0] += correct_count
        memo[group][1] += 1
        memo
      end

      result = sum_per_group.map {|arr| arr[0] / arr[1]}

      {question_id => result}
    end

    hashes.reduce({}, :merge)
  end
end