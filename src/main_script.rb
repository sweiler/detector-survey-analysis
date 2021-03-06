
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
require_relative 'statsig'
require_relative 'boxplot'
require_relative 'boxplot_diagram'

module MainScript
  extend Helper

  def self.survey_structure
    SurveyStructure.default_survey_structure
  end

  def self.pre_audited_data(filename)
    data = Parser.parse_file(filename)
    dhl_name = filename.sub(/\.[^.]+\z/, '_dhl.csv')
    if File.exist?(dhl_name)
      data_dhl = Parser.parse_file(dhl_name)
      data += data_dhl
    end
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
    augmented_data.reject! {|row| row == {}}

    if ARGV[1] == '--select-usable-rows'

      keys_to_show = %w(id lastpage randMultiple listCheck listCheckAdesc listCheckAsolve createFile createFileAdesc createFileAsolve)
      augment_manually(augmented_data, json_name, keys_to_show, manual_data, :usefulMultiple)

      keys_to_show = %w(id lastpage randGraph fisGraph fisGraphDesc fisGraphSolve cipherGraph cipherGraphDesc cipherGraphSolve)
      augment_manually(augmented_data, json_name, keys_to_show, manual_data, :usefulGraph)

      exit
    elsif ARGV[1] == '--manual-assessment'
      keys_to_show = %w(id listCheck listCheckAdesc listCheckAsolve)
      d = UsableDataFilter.new.filter_with_flag(augmented_data, :usefulMultiple)

      augment_manually(d, json_name, keys_to_show, manual_data, :understoodListCheck)

      keys_to_show = %w(id createFile createFileAdesc createFileAsolve)
      augment_manually(d, json_name, keys_to_show, manual_data, :understoodCreateFile)

      d = UsableDataFilter.new.filter_with_flag(augmented_data, :usefulGraph)
      keys_to_show = %w(id fisGraph fisGraphDesc fisGraphSolve)
      augment_manually(d, json_name, keys_to_show, manual_data, :understoodFisExists)

      keys_to_show = %w(id cipherGraph cipherGraphDesc cipherGraphSolve)
      augment_manually(d, json_name, keys_to_show, manual_data, :understoodCipher)

      exit
    end


    yes_no_questions = self.survey_structure.grouped_questions_with_type(:yes_no)

    puts yes_no_questions
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
      fields.each do |field|
        timing_key = (field.to_s + 'Time').to_sym
        (0..2).each do |group_a|
          (0..2).each do |group_b|
            if group_a != group_b
              sig = Statsig.significance_a_greater_b_binary(usable_data, group_key, group_a, group_b, field)
              puts "significance niveau for #{group_key} #{group_a} > #{group_b} in #{field}: #{sig}" if sig < 0.15
            end
          end
        end
      end
      Diagram.new_yes_no(self.survey_structure.group_labels_for_group(group_key), diagram_data).write_file(group_key.to_s + '.svg')


    end

    boxplots = survey_structure.grouped_questions_with_type(:time)
    boxplots.each do |group_key, fields|
      usable_data = UsableDataFilter.new.filter_with_flag(augmented_data, survey_structure.usable_flag_for_group(group_key))

      fields.each do |field|
        boxplots = []
        (0..2).each do |group_idx|
          d = usable_data.reject {|row| row[field] > 1000}
          boxplot = Boxplot.new(d, group_key, group_idx, field)
          puts "Median for #{field} in group #{group_idx}: #{boxplot.median}"
          boxplots.push(boxplot)
        end
        BoxplotDiagram.new(boxplots).write_file(field.to_s + '.svg')
      end

    end

    data = UsableDataFilter.new.filter(data)
    puts "Participants general: #{data.length}"
    matrix = MatrixQuestionStats.new(survey_structure, data)
    matrix.histogram.each do |question, subquestion_data|
      group = self.survey_structure.grouping_for_question((question.to_s + 'Time').to_sym)

      subquestion_data.each do |subquestion, histograms|
        Histogram.new(self.survey_structure.group_labels_for_group(group), histograms).write_file(subquestion.to_s + '.svg')
      end

    end
    group_dist = GroupDistribution.new(self.survey_structure, data)
    puts 'Group distribution:'
      puts group_dist.counts[:randConf].each_with_index.map {|g, i| "#{survey_structure.group_labels_for_group(:randConf)[i]}: #{g}"}
      puts ''

    puts matrix.correctness
  end

  def self.augment_manually(data, json_name, keys_to_show, manual_data, field)
    data.each do |row|
      if row[field].nil?
        cpy = row.clone
        cpy.keep_if { |key, _| keys_to_show.include? key.to_s }

        puts JSON.pretty_generate(cpy)
        puts ''
        puts field.to_s
        puts '(Y)es, (N)o or (S)kip: > '
        selection = $stdin.gets.chomp.upcase
        if selection == 'Y'
          puts 'Saved as Yes'
          manual_data.add_data(row[:id], {field => true})
        elsif selection == 'N'
          puts 'Saved as No'
          manual_data.add_data(row[:id], {field => false})
        else
          puts 'The row is skipped.'
        end

        File.write(json_name, manual_data.to_json)
        puts ''
        puts ''
      end
    end
  end
end
