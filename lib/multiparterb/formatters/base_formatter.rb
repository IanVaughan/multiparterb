module MultipartErb
  class BaseFormatter
    include ActionView::Helpers::TagHelper
    include ActionView::Context

    def heading(text)
      raise NotImplementedError
    end

    def text(text)
      raise NotImplementedError
    end

    def anchor(text, href)
      raise NotImplementedError
    end

    def unordered_list(text)
      raise NotImplementedError
    end
  end
end
