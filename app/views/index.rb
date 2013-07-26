class App
  module Views
    class Index < Layout
   	  def local_uploads
   	  	@local_uploads
   	  end

   	  def s3_originals
   	  	@s3_originals
   	  end

   	  def s3_watermarked
   	  	@s3_watermarked
   	  end

   	  def watermarked_urls
   	  	@watermarked_urls
   	  end   	     	     	      	
    end
  end
end
