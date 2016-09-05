class SurveyStructure
  private
  def self.default_survey_structure
    self.new({
        :question_types => {
            :listCheck => :yes_no,
            :createFile => :yes_no,
            :fisGraph => :yes_no,
            :cipherGraph => :yes_no,
            :jdbcConfN => :matrixA1A5,
            :byteBufferConfN => :matrixA1A5
        },
        :sub_questions => {
            :jdbcConfN => {
                'jdbcConfN[resSet]'.to_sym => 'A2',
                'jdbcConfN[setEm]'.to_sym => 'A1',
                'jdbcConfN[try]'.to_sym => 'A4',
                'jdbcConfN[file]'.to_sym => 'A3',
                'jdbcConfN[stmtClose]'.to_sym => 'A4'
            },
            :byteBufferConfN => {
                'byteBufferConfN[compact]'.to_sym => 'A2',
                'byteBufferConfN[rafSeek]'.to_sym => 'A3',
                'byteBufferConfN[flip]'.to_sym => 'A4',
                'byteBufferConfN[stringbuf]'.to_sym => 'A1'
            }
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
    })
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

  public

  def initialize(structure)
    @structure = structure
  end

  def questions_with_type(question_type)
    @structure[:question_types].keys.select {|key| @structure[:question_types][key] == question_type}
  end

  def grouped_questions_with_type(question_type)
    hashes = questions_per_group.map do |group, questions|
      res = questions.select { |question_id| @structure[:question_types][question_id] == question_type }
      {group => res}
    end
    hashes.reduce({}, :merge).reject { |_, questions| questions.empty? }
  end

  def questions_per_group
    @structure[:random_groups_questions].map {|key, value| {key => value.flatten}}.reduce({}, :merge)
  end

  def grouping_for_question(question_id)
    arr = questions_per_group.keys.select {|key| questions_per_group[key].include? question_id }
    arr[0]
  end

  def random_groups_max_value
    array_of_hashs = @structure[:random_groups_questions].map do |key, value|
      {key => value.length - 1}
    end
    array_of_hashs.reduce({}, :merge)
  end

  def random_groups_questions
    @structure[:random_groups_questions]
  end

  def sub_questions(question)
    @structure[:sub_questions][question]
  end
end