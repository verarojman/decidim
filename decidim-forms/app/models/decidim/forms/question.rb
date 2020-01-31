# frozen_string_literal: true

module Decidim
  module Forms
    # The data store for a Question in the Decidim::Forms component.
    class Question < Forms::ApplicationRecord
      TYPES = %w(short_answer long_answer single_option multiple_option sorting).freeze

      belongs_to :questionnaire, class_name: "Questionnaire", foreign_key: "decidim_questionnaire_id"

      has_many :answer_options,
               class_name: "AnswerOption",
               foreign_key: "decidim_question_id",
               dependent: :destroy,
               inverse_of: :question

      has_many :conditions,
               class_name: "QuestionCondition",
               foreign_key: "decidim_question_id",
               dependent: :destroy,
               inverse_of: :question

      has_many :conditioned_questions, through: :conditions, source: "decidim_forms_question_condition_id"

      validates :question_type, inclusion: { in: TYPES }

      def multiple_choice?
        %w(single_option multiple_option sorting).include?(question_type)
      end

      def mandatory_body?
        mandatory? && !multiple_choice?
      end

      def mandatory_choices?
        mandatory? && multiple_choice?
      end

      def number_of_options
        answer_options.size
      end
    end
  end
end
