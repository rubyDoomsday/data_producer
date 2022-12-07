# frozen_string_literal: true

class DataSourcesController < ApplicationController
  def create
    data_source = DataSource.new(data_source_params)
    if data_source.valid?
      data_source.save
      render json: data_source, status: :created
    else
      render_errors(data_source.errors, :bad_request)
    end
  end

  def show
    data_source = DataSource.find_by(id: params[:id])
    return render_errors("not found", :not_found) unless data_source

    render json: data_source, status: :ok
  end

  def index
    data_sources = DataSource.all

    render json: data_sources, status: :ok
  end

  def update
    data_source = DataSource.find_by(id: params[:id])
    return render_errors("not found", :not_found) unless data_source

    if data_source.update(data_source_params)
      render json: data_source, status: :ok
    else
      render_errors(data_source.errors, status)
    end
  end

  def destroy
    data_source = DataSource.find_by(id: params[:id])
    return render_errors("not found", :not_found) unless data_source

    data_source.destroy
    render json: {}, status: :no_content
  end

  private

  def data_source_params
    @data_source_params ||= params
      .require(:data_source)
      .permit(*permitted_params)
  end

  def render_errors(errors, status)
    render json: {errors: Array(errors)}, status: status
  end

  def permitted_params
    %i[
      title
      source_type
      summary
      status_code
    ]
  end
end
