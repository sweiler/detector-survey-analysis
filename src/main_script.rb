
require 'json'
require_relative 'parser'
require_relative 'usable_data_filter'
require_relative 'group_distribution'
require_relative 'group_divider'
require_relative 'stats'
require_relative 'helper'
require_relative 'survey_structure'
require_relative 'matrix_question_stats'
require_relative 'diagram'
require_relative 'manual_data'

module MainScript
  extend Helper

  def self.survey_structure
    SurveyStructure.default_survey_structure
  end

  def self.pre_audited_data(filename)
    data = Parser.parse_file(filename)
    data = GroupDivider.new(survey_structure).divide(data)
  end

  def self.run
    filename = ARGV[0]

    if filename.nil?
      puts 'results analyzer'
      puts '--------------------------'
      puts ''
      puts 'Please provide an csv file as the first argument'

      exit
    end

    manual_data = ManualData.new

    data = pre_audited_data(filename)
    json_name = filename.sub /\.[^.]+\z/, '-manual-data.json'

    if File.exist? json_name
      manual_data = ManualData.new(File.read(json_name))
    end

    augmented_data = manual_data.augment(data)

    if ARGV[1] == '--select-usable-rows'

      augmented_data.each do |row|
        cpy = row.clone
        keys_to_show = %w(id lastpage randMultiple listCheck listCheckAdesc listCheckAsolve createFile createFileAdesc createFileAsolve fisGraph fisGraphDesc fisGraphSolve cipherGraph cipherGraphDesc cipherGraphSolve)
        cpy.keep_if {|key, _| keys_to_show.include? key.to_s}
        puts JSON.pretty_generate(cpy)
        puts ''
        puts 'Is this row useful for multiple patterns?'
        puts '(Y)es, (N)o or (S)kip: > '
        selection = $stdin.gets.chomp.upcase
        if selection == 'Y'
          puts 'This row is saved as useful.'
          manual_data.add_data(row[:id], {:usefulMultiple => true})
        elsif selection == 'N'
          puts 'This row is saved as not useful.'
          manual_data.add_data(row[:id], {:usefulMultiple => false})
        else
          puts 'This row is skipped. Run the command again to change your selection.'
        end
        puts ''
        puts 'Is this row useful for graph patterns?'
        puts '(Y)es, (N)o or (S)kip: > '
        selection = $stdin.gets.chomp.upcase
        if selection == 'Y'
          puts 'This row is saved as useful.'
          manual_data.add_data(row[:id], {:usefulGraph => true})
        elsif selection == 'N'
          puts 'This row is saved as not useful.'
          manual_data.add_data(row[:id], {:usefulGraph => false})
        else
          puts 'This row is skipped. Run the command again to change your selection.'
        end

        puts ''
        puts ''
      end

      File.write(json_name, manual_data.to_json)

      exit
    end


    yes_no_questions = self.survey_structure.grouped_questions_with_type(:yes_no)


    yes_no_questions.each do |group_key, fields|
      diagram_data = {}
      usable_data = UsableDataFilter.new.filter_with_flag(augmented_data, survey_structure.usable_flag_for_group(group_key))

      group_dist = GroupDistribution.new(self.survey_structure, usable_data)
      stats = Stats.new(usable_data)

      duration_secs = stats.avg(:interviewtime)

      min_duration = stats.min(:interviewtime)
      max_duration = stats.max(:interviewtime)

      puts "Results for grouping with #{group_key.to_s}"
      puts "Interview duration: avg: #{format_duration(duration_secs)}, min: #{format_duration(min_duration)}, max: #{format_duration(max_duration)}"
      puts ''

      puts 'Group distribution:'
      puts group_dist.counts[group_key].each_with_index.map {|g, i| "#{survey_structure.group_labels_for_group(group_key)[i]}: #{g}"}
      puts ''

      (0..2).each do |idx|
        fields.each do |field|
          field_label = self.survey_structure.field_label(field)
          if diagram_data[field_label].nil?
            diagram_data[field_label] = [0, 0, 0]
          end
          ratio = stats.yes_no_ratio_with_group(field, group_key, idx)
          diagram_data[field_label][idx] = ratio
        end
      end
      Diagram.new_yes_no(self.survey_structure.group_labels_for_group(group_key), diagram_data).write_file(group_key.to_s + '.svg')
    end

    data = UsableDataFilter.new.filter(data)

    matrix = MatrixQuestionStats.new(survey_structure, data)
    matrix.histogram.each do |question, subquestion_data|
      group = self.survey_structure.grouping_for_question((question.to_s + 'Time').to_sym)
      subquestion_data.each do |subquestion, histograms|
        Histogram.new(self.survey_structure.group_labels_for_group(group), histograms).write_file(subquestion.to_s + '.svg')
      end

    end
    
    puts matrix.correctness
  end
end
