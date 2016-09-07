class MatrixQuestionStats
  def initialize(survey_structure, data)
    @survey_structure = survey_structure
    @data = data
  end

  def correctness
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

  def histogram
    possible_values = %w(A1 A2 A3 A4 A5)
    hashes = questions.map do |question_id|
      sub_questions = @survey_structure.sub_questions(question_id)
      question_grouping_id = @survey_structure.grouping_for_question(sub_questions.keys[0])
      max_grouping_value = @survey_structure.random_groups_max_value[question_grouping_id]

      sub_hashes = sub_questions.keys.map do |sub_question_id|
        histograms = (0..max_grouping_value).map do |group|
          histo = [0, 0, 0, 0, 0]
          sum = 0.0
          @data.each do |row|
            if row[question_grouping_id] == group
              value = row[sub_question_id]
              histo[possible_values.index(value)] += 1
              sum += 1
            end
          end
          histo.map {|v| v / sum}
        end
        {sub_question_id => histograms}
      end
      res = sub_hashes.reduce({}, :merge)

      {question_id => res}
    end

    hashes.reduce({}, :merge)
  end

  private
  def questions
    @survey_structure.questions_with_type(:matrixA1A5)
  end
end