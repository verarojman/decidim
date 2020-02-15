# frozen_string_literal: true

require "spec_helper"
require "decidim/dev/test/form_to_param_shared_examples"

module Decidim
  module Forms
    module Admin
      describe DisplayConditionForm do
        subject do
          described_class.new(decidim_question_id: decidim_question_id,
                              decidim_condition_question_id: decidim_condition_question_id,
                              condition_value: condition_value,
                              condition_type: condition_type,
                              decidim_answer_option_id: decidim_answer_option_id,
                              mandatory: true).with_context(current_organization: organization)
        end

        let(:organization) { create(:organization) }
        let(:condition_question) { create(:questionnaire_question, position: 1) }
        let(:decidim_condition_question_id) { condition_question.id }
        let(:question) { create(:questionnaire_question, position: 2) }
        let(:decidim_question_id) { question.id }
        let(:answer_option) { create(:answer_option, question: condition_question) }
        let(:decidim_answer_option_id) { answer_option.id }

        let(:condition_type) { :answered }
        let(:condition_value) do
          {
            en: "Text en",
            ca: "Text ca",
            es: "Text es"
          }
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when decidim_question_id is not present" do
          let!(:decidim_question_id) { nil }

          it { is_expected.not_to be_valid }
        end

        context "when decidim_condition_question_id is not present" do
          let!(:decidim_condition_question_id) { nil }
          let!(:decidim_answer_option_id) { nil } # otherwise it will try to use condition_question overriden in previous line

          it { is_expected.not_to be_valid }
        end

        context "when the condition_type is not present" do
          let!(:condition_type) { nil }

          it { is_expected.not_to be_valid }
        end

        context "when the condition_value is missing a locale translation" do
          let(:condition_type) { :match }

          before do
            condition_value[:en] = ""
          end

          it { is_expected.not_to be_valid }
        end

        context "when condition_question is positioned before question" do
          let!(:question) { create(:questionnaire_question, position: 3) }
          let!(:condition_question) { create(:questionnaire_question, position: 5) }

          it { is_expected.not_to be_valid }
        end

        context "when answer_option is not from condition_question" do
          let(:condition_type) { :equal }
          let(:answer_option) { create(:answer_option) }

          it { is_expected.not_to be_valid }
        end

        context "when answer_option is mandatory" do
          let!(:condition_type) { :equal }
          let!(:answer_option_id) { nil }

          it { is_expected.not_to be_valid }
        end

        context "when it is deleted" do
          let!(:condition_type) { :equal }
          let!(:condition_value) { nil }
          let!(:decidim_answer_option_id) { nil }

          before do
            subject.deleted = true
          end

          it { is_expected.to be_valid }
        end

        it_behaves_like "form to param", default_id: "questionnaire-display-condition-id"
      end
    end
  end
end