require 'open-uri'
require 'net/http'
require 'uri'

# 
# Creates a cache of html files from url requests. If it receives a url it already has downloaded, will return the locally cached file.
# USAGE:
# you first initialize the cache with a path to a folder to store the responses
# 
# rc = RequestCache.new("caches/patent_pages")
# 
# Then you initiate a response with
# rc.get("http://www.shancarter.com")
# 


class RequestCache
    attr_accessor :folder_path
    @data = []
    @data_path = ""
    @downloads_path = ""
    @current_id = 0
    # url | file_name

    # constructor
    def initialize(path)
        @folder_path = path
        if !File.directory?(@folder_path)
            Dir.mkdir(@folder_path)
        end
        
        
        @data = []
        @current_id = 0
        @data_path = @folder_path + "/lookup.txt"
        # test for lookup file, if not there create it.
        if File.exists?(@data_path)
            # parse the data
            
            count = 0
            File.open(@data_path, 'r').each do |line|
                fn = line.split("\t")[0]
                url = line.split("\t")[1].gsub!("\n", "")
                @data << { :url => url, :file_name => fn }
                count += 1
            end
            @current_id = @data.length
            
        else
            # create the data file
            File.new(@data_path, "w")
        end
        
        # test for downloads folder, if not there create it.
        @downloads_path = @folder_path + "/downloads"
        if !File.directory?(@downloads_path)
            Dir.mkdir(@downloads_path)
        end
        
        
    end
    
    
    def get(url)
        puts url
        
        # find in cache data
        if !@data.nil?
            @data.each do |r|
                if url == r[:url]
                    puts "found"
                    puts r[:file_name]
                    path = @downloads_path + "/" + r[:file_name]
                    out = ""
                    open(path).each do |line|
                        out << line
                    end
                    return out
                end
            end
        end
        
        
        # if not there, download it
        puts "not found"
        file_location = @downloads_path + "/#{@current_id.to_s}.txt"
        if File.exists?(file_location)
           raise "Trying to write to a file that already exists" 
        end
        
        response = Net::HTTP.get_response(URI.parse(url))
        open(file_location, "w") do |out|
            out.puts response.body
        end
        
        @data << {:url => url, :file_name => "#{@current_id.to_s}.txt"}
        save()
        @current_id = @current_id + 1
        return response.body
    end
    
    
    def save
        # save the data
        
        out = ""
        @data.each do |r|
            out << (r[:file_name] + "\t" +r[:url] + "\n")
        end
        out.chomp!("\n").chomp!("\n")
        
        File.open(@data_path, 'w') do |f|
            f.puts out
        end
        
    end
    

end