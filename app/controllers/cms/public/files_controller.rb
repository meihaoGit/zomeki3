# encoding: utf-8
class Cms::Public::FilesController < ApplicationController
  def down
    return http_error(404) if params[:path] !~ /^[^\/]+\/[^\/]+$/
    id   = params[:path].gsub(/\/.*/, '')
    name = params[:path].gsub(/.*\//, '') + '.' + params[:format].to_s

    item = Cms::DataFile.public.where(id: id.gsub(/.\z/, ''), name: name).first
    return http_error(404) unless item

    path = item.public_path
    return http_error(404) unless FileTest.exist?(path)
    
    if img = item.mobile_image(request.mobile, :path => item.public_path)
      return send_data(img.to_blob, :type => item.mime_type, :filename => item.name, :disposition => 'inline')
    end
    
    return send_file(path, :type => item.mime_type, :filename => item.name, :disposition => 'inline')
  end
end
