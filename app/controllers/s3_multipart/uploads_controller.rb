module S3Multipart
  class UploadsController < ApplicationController

    def create
      begin
        logger.debug "create route"
        logger.info params
        upload = Upload.create(params)
        logger.debug "created upload model"
        upload.execute_callback(:begin, session)
        logger.debug "executed callback"
        response = upload.to_json
        logger.debug "completed upload to_json"
        logger.debug response
      rescue FileTypeError, FileSizeError => e
        response = {error: e.message}
      rescue => e
        logger.error "EXC: #{e.message}"
        logger.error e.backtrace
        response = { error: t("s3_multipart.errors.create") }
      ensure
        render :json => response
      end
    end

    def update
      return complete_upload if params[:parts]
      return sign_batch if params[:content_lengths]
      return sign_part if params[:content_length]
    end

    private

      def sign_batch
        begin
          response = Upload.sign_batch(params)
        rescue => e
          logger.error "EXC: #{e.message}"
          response = {error: t("s3_multipart.errors.update")}
        ensure
          render :json => response
        end
      end

      def sign_part
        begin
          response = Upload.sign_part(params)
        rescue => e
          logger.error "EXC: #{e.message}"
          response = {error: t("s3_multipart.errors.update")}
        ensure
          render :json => response
        end
      end

      def complete_upload
        begin
          response = Upload.complete(params)
          upload = Upload.find_by_upload_id(params[:upload_id])
          upload.update_attributes(location: response[:location])
          data = {}
          upload.execute_callback(:complete, session, data)
          response.merge!({custom_data: data})
        rescue => e
          logger.error "EXC: #{e.message}"
          logger.error e.backtrace
          response = {error: t("s3_multipart.errors.complete")}
        ensure
          render :json => response
        end
      end

  end
end
