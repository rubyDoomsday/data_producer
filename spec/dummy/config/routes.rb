# frozen_string_literal: true

Rails.application.routes.draw do
  mount DataProducer::Engine => "/data_producer"

  resources :data_sources, only: %i[index create show update destroy]
end
