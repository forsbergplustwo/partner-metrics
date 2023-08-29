# Allows for creating fixtures from your console, based on DB records in development.
# Source: https://stackoverflow.com/a/70618670
# Usage: Metric.find(1).dump_fixture or User.find(1).dump_fixture(include_attachments: true)

class ActiveRecord::Base
  # Append this record to the fixture.yml for this record class
  def dump_fixture(name: nil, include_attachments: false)
    # puts "Dumping fixture for #{self.class.name} id=#{id} #{"with name #{name}" if name}"

    attributes_to_exclude = [:updated_at, :created_at, *Rails.application.config.filter_parameters].map(&:to_s)
    attributes_to_exclude << "id" if !name.nil?

    # puts "  Attributes excluded: #{attributes_to_exclude.inspect}"

    attributes_to_dump = attributes
      .except(*attributes_to_exclude)
      .reject { |k, v| v.blank? }

    name = "#{self.class.table_name.singularize}_#{id}" if name.nil?

    dump_raw_fixture({name => attributes_to_dump}.to_yaml.sub(/---\s?/, "\n"))

    if include_attachments != false
      self.class.reflect_on_all_attachments
        .each { |association|
          a_name = association.name
          Array(send(a_name.to_sym)).each_with_index { |attachment, index|
            attachment_name = "#{name}_#{a_name.to_s.underscore}_#{index}"
            blob_name = "#{attachment_name}_blob"

            attachment.dump_raw_fixture({name => {
              "name" => a_name,
              "record" => "#{name} (#{self.class.name})",
              "blob" => blob_name
            }}.to_yaml.sub(/---\s?/, "\n"))

            blob = attachment.blob
            blob.dump_raw_fixture("#{blob_name}: <%= ActiveStorage::Blob.fixture(filename: '#{blob.filename}') %>\n")
            blob_path = "#{Rails.root}/test/fixtures/files/#{blob.filename}"
            File.open(blob_path, "wb+") do |file|
              blob.download { |chunk| file.write(chunk) }
            end
          }
        }
    end
  end

  def dump_raw_fixture(text)
    fixture_file = "#{Rails.root}/test/fixtures/#{self.class.name.underscore.pluralize}.yml"
    File.open(fixture_file, "a+") do |f|
      f.puts(text)
    end
  end
end
