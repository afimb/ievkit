module Ievkit
  class Job
    attr_reader :client, :response

    def initialize(referential_id)
      @client = Ievkit::Client.new(referential_id)
    end

    def post_job(action, type = nil, options = {})
      send(action, type, options)
    end

    def get_job(url)
      do_job(url, :get)
    end

    def delete_job(url)
      do_job(url, :delete)
    end

    def delete_jobs
      do_job(@client.iev_url_jobs, :delete)
    end

    def terminated_job?(url)
      get_job(url).to_s.include?('terminated_jobs')
    end

    def get_stats
      @client.get_stats
    end

    def list_tests(action, format)
      @client.list_tests(action, format)
    end

    def download_validation_report(data, errors)
      csv = []
      csv << "\uFEFF;Statut/Information;Nombre d'erreurs;Nombre d'avertissements"
      data.each do |el|
        t = [el[:name], I18n.t("compliance_check_results.severities.#{el[:status]}"), el[:count_error], el[:count_warning]]
        csv << t.join(';')
        next unless el[:check_point_errors]
        el[:check_point_errors].each do |index|
          error = errors[index]
          next unless error
          t = []
          esf = error[:source][:file]
          if esf && esf[:filename]
            filename = []
            filename << "#{I18n.t('report.file.line')} #{esf[:line_number]}" if esf[:line_number].to_i > 0
            filename << "#{I18n.t('report.file.column')} #{esf[:column_number]}" if esf[:column_number].to_i > 0
            t << filename.join(' ') if filename.present?
          end
          t << error[:error_name]
          csv << ';'+t.join(' ')
        end
      end
      csv.join("\n")
    end

    protected

    def do_job(url, http_method)
      @client.prepare_request(url, http_method)
    end

    def importer(type, options)
      @client.prepare_post_request(type, options)
    end

    def exporter(type, options)
      @client.prepare_post_request(type, options)
    end

    def converter(type, options)
      @client.prepare_post_request(type, options)
    end

    def validator(type, options)
      @client.prepare_post_request(type, options)
    end
  end
end
