class GroupDivider
  def self.divide(data)
    self.new(data).run
  end

  def initialize(data)
    @data = data
  end

  def run
    @data.map do |row|

     fields_per_group = group_field_associations.map do |rand_field, grouped_fields|
        rand_group = row[rand_field]
        if rand_group.nil?
          {}
        else
          group_zero_fields = grouped_fields[0]

          real_group_fields = grouped_fields[rand_group]
          new_field_assocs = real_group_fields.each_with_index.map do |field_id, idx|
            field_name_in_group_zero = group_zero_fields[idx]
            field_value_in_row = row[field_id]

            if field_value_in_row.nil?
              {}
            else
              {field_name_in_group_zero => field_value_in_row}
            end
          end

          fields_for_this_group = new_field_assocs.reduce({}, :merge)
          fields_for_this_group[rand_field] = rand_group

          fields_for_this_group
        end
      end

      new_row = remove_additional_fields(row)
      new_fields = fields_per_group.reduce({}, :merge)
      new_row.merge(new_fields)
    end
  end

  def remove_additional_fields(row)
    keys_to_remove = group_field_associations.keys
    keys_to_remove += group_field_associations.values.map {|ary| ary[1] + ary[2]}.flatten
    Hash[row.reject { |key| keys_to_remove.include? key }]
  end

  def group_field_associations
    {
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
        :randConf => rand_conf_data
    }
  end

  def rand_conf_data
    jdbc_additions = %w[resSet setEm try file stmtClose]
    byte_buffer_additions = %w[compact rafSeek flip stringbuf]

    [
        [
          all_variants('jdbcConfN', jdbc_additions),
          all_variants('byteBufferConfN', byte_buffer_additions),
          :jdbcConfNTime, :byteBufferConfNTime
        ].flatten,
        [
          all_variants('jdbcConfC', jdbc_additions),
          all_variants('byteBufferConfC', byte_buffer_additions),
          :jdbcConfCTime, :byteBufferConfCTime
        ].flatten,
        [
          all_variants('jdbcConfW', jdbc_additions),
          all_variants('byteBufferConfW', byte_buffer_additions),
          :jdbcConfWTime, :byteBufferConfWTime
        ].flatten,
    ]
  end

  def all_variants(base, additions)
    additions.map do |add|
      "#{base}[#{add}]".to_sym
    end.flatten
  end
end