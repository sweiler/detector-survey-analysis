require 'json'

require_relative 'parser'
require_relative 'usable_data_filter'
require_relative 'group_distribution'
require_relative 'group_divider'
require_relative 'stats'
require_relative 'helper'
require_relative 'survey_structure'
require_relative 'matrix_question_stats'

module MainScript
  extend Helper

  def self.survey_structure
    SurveyStructure.default_survey_structure
  end

  def self.pre_audited_data(filename)
    usable_data_filter = UsableDataFilter.new
    data = Parser.parse_file(filename)
    data = usable_data_filter.filter(data)
    GroupDivider.new(survey_structure).divide(data)
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

    data = pre_audited_data(filename)
    puts "Usable results: #{data.length}"

    group_dist = GroupDistribution.new(self.survey_structure, data)
    stats = Stats.new(data)

    duration_secs = stats.avg(:interviewtime)

    min_duration = stats.min(:interviewtime)
    max_duration = stats.max(:interviewtime)


    puts "Interview duration: avg: #{format_duration(duration_secs)}, min: #{format_duration(min_duration)}, max: #{format_duration(max_duration)}"
    puts ''

    puts group_dist.counts
    puts ''

    yes_no_questions = self.survey_structure.grouped_questions_with_type(:yes_no)

    yes_no_questions.each do |group_key, fields|

      (0..2).each do |idx|
        puts "Stats for #{group_key} == #{idx}"
        fields.each do |field|
          ratio = stats.yes_no_ratio_with_group(field, group_key, idx)
          ratio = (ratio * 10000).round / 100.0
          puts "#{field} is #{ratio}%"
        end
        puts ''
      end

      puts ''
      puts '------------------------------'
      puts ''
    end

    puts 'CONFIDENCE:'
    puts '----------------------------'
    matrix = MatrixQuestionStats.new(survey_structure, data)
    puts matrix.correctness

  end
end