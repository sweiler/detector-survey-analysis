class SurveyStructure

  def self.survey_structure
    {
        :question_types => {
            :listCheck => :yes_no,
            :createFile => :yes_no,
            :fisGraph => :yes_no,
            :cipherGraph => :yes_no
        },
        :random_groups_questions => {
            :randMultiple => [
                [
                    :listCheck, :listCheckTime, :listCheckAdesc, :listCheckAdescTime, :listCheckAsolve, :listCheckAsolveTime,
                    :createFile, :createFileTime, :createFileAdesc, :createFileAdescTime, :createFileAsolve, :createFileAsolveTime,
                ],
                [
                    :listCheckControl, :listCheckControlTime, :listCheckCdesc, :listCheckCdescTime, :listCheckCsolve, :listCheckCsolveTime,
                    :createFileControl, :createFileControlTime, :createFileCdesc, :createFileCdescTime, :createFileCsolve, :createFileCsolveTime,
                ],
                [
                    :listCheckC2, :listCheckC2Time, :listCheckC2desc, :listCheckC2descTime, :listCheckC2solve, :listCheckC2solveTime,
                    :createFileC2, :createFileC2Time, :createFileC2desc, :createFileC2descTime, :createFileC2solve, :createFileC2solveTime,
                ]
            ],
            :randGraphJava => [
                [
                    :fisGraph, :fisGraphDesc, :fisGraphSolve, :cipherGraph, :cipherGraphDesc, :cipherGraphSolve,
                    :fisGraphTime, :fisGraphDescTime, :fisGraphSolveTime, :cipherGraphTime, :cipherGraphDescTime, :cipherGraphSolveTime,
                ],
                [
                    :fisTT, :fisTTDesc, :fisTTSolve, :cipherTT, :cipherTTDesc, :cipherTTSolve,
                    :fisTTTime, :fisTTDescTime, :fisTTSolveTime, :cipherTTTime, :cipherTTDescTime, :cipherTTSolveTime,
                ],
                [
                    :fisJava, :fisJavaDesc, :fisJavaSolve, :cipherJava, :cipherJavaDesc, :cipherJavaSolve,
                    :fisJavaTime, :fisJavaDescTime, :fisJavaSolveTime, :cipherJavaTime, :cipherJavaDescTime, :cipherJavaSolveTime,
                ]
            ],
            :randConf => self.confidence_questions
        }
    }
  end

  def self.confidence_questions
    jdbc_additions = %w[resSet setEm try file stmtClose]
    byte_buffer_additions = %w[compact rafSeek flip stringbuf]

    [
        [
            self.all_variants('jdbcConfN', jdbc_additions),
            self.all_variants('byteBufferConfN', byte_buffer_additions),
            :jdbcConfNTime, :byteBufferConfNTime
        ].flatten,
        [
            self.all_variants('jdbcConfC', jdbc_additions),
            self.all_variants('byteBufferConfC', byte_buffer_additions),
            :jdbcConfCTime, :byteBufferConfCTime
        ].flatten,
        [
            self.all_variants('jdbcConfW', jdbc_additions),
            self.all_variants('byteBufferConfW', byte_buffer_additions),
            :jdbcConfWTime, :byteBufferConfWTime
        ].flatten,
    ]
  end


  def self.all_variants(base, additions)
    additions.map do |add|
      "#{base}[#{add}]".to_sym
    end.flatten
  end

  def self.grouped_questions_with_type(question_type)
    hashes = questions_per_group.map do |group, questions|
      res = questions.select { |question_id| self.survey_structure[:question_types][question_id] == question_type }
      {group => res}
    end
    hashes.reduce({}, :merge).reject { |_, questions| questions.empty? }
  end

  def self.questions_per_group
    self.survey_structure[:random_groups_questions].map {|key, value| {key => value.flatten}}.reduce({}, :merge)
  end

  def self.random_groups_max_value
    array_of_hashs = self.survey_structure[:random_groups_questions].map do |key, value|
      {key => value.length - 1}
    end
    array_of_hashs.reduce({}, :merge)
  end

  def self.random_groups_questions
    self.survey_structure[:random_groups_questions]
  end
end