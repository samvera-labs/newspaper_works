module NewspaperWorks
  # validates that a properly formatted date has been entered
  class PublicationDateStartEndValidator < ActiveModel::Validator
    DATE_RANGE_REGEX = /\A\d{4}(-((0[1-9])|(1[0-2])))?(-(([0-2][1-9])|3[0-1]))?\z/
    def validate(record)
      date_incorrect_msg = "Incorrect Date. Date input should be formatted yyyy[-mm][-dd] and be a valid date."
      end_before_start_msg = "Publication start date must be earlier or the same as end date."
      record.errors[:publication_date_start] << date_incorrect_msg if record.publication_date_start.present? && !publication_date_valid?(record.publication_date_start)
      record.errors[:publication_date_end] << date_incorrect_msg if record.publication_date_end.present? && !publication_date_valid?(record.publication_date_end)

      return unless record.publication_date_start.present? && record.publication_date_end.present? &&
                    publication_date_valid?(record.publication_date_start) &&
                    publication_date_valid?(record.publication_date_end)

      pub_start = record.publication_date_start.split("-")
      pub_end = record.publication_date_end.split("-")
      (0..2).each do |i|
        record.errors[:publication_date_start] << end_before_start_msg if pub_start[i] && pub_end[i] && pub_end[i] < pub_start[i]
      end
    end

    private

      def publication_date_valid?(pub_date)
        return false unless DATE_RANGE_REGEX.match(pub_date)
        date_split = pub_date.split("-").map(&:to_i)
        return false if date_split.length == 3 &&
                        !Date.valid_date?(date_split[0], date_split[1], date_split[2])
        true
      end
  end
end
