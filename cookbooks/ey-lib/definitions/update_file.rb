$update_file_path_change_index = Hash.new {|h,k| h[k] = 0}

define :update_file, :action => :append do

  filepath = params[:path] || params[:name]
  index = $update_file_path_change_index[filepath] += 1

  file filepath do
    action :create_if_missing
    backup params[:backup] if params[:backup]
    group params[:group] if params[:group]
    mode params[:mode] if params[:mode]
    owner params[:owner] if params[:owner]
    path filepath
    not_if params[:not_if] if params[:not_if]
    only_if params[:only_if] if params[:only_if]
  end

  case params[:action].to_sym
  when :append, :rewrite

    mode = params[:action].to_sym == :append ? '>>' : '>'

    execute "updating #{filepath} (##{index}): #{params[:action].to_s.sub(/e$/,'')}ing" do
      command "echo '#{params[:body]}' #{mode} #{filepath}"
      not_if params[:not_if] if params[:not_if]
      only_if params[:only_if] if params[:only_if]
    end

  when :truncate

    execute "updating #{filepath} (##{index}): truncating" do
      command ">| #{filepath}"
      not_if params[:not_if] if params[:not_if]
      only_if params[:only_if] if params[:only_if]
    end

  end
end
