describe RSolr::Message do
  
  
  builder = RSolr::Message::Builder.new
  
  # call all of the simple methods...
  # make sure the xml string is valid
  # ensure the class is actually Solr::XML
  it 'should create xml when calling these simple methods' do
    [:optimize, :rollback, :commit].each do |meth|
      result = builder.send(meth)
      result.should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?><#{meth}/>"
    end
  end
  
  it 'should yield a Message::Document object when #add is called with a block' do
    documents = [{:id=>1, :name=>'sam', :cat=>['cat 1', 'cat 2']}]
    add_attrs = {:boost=>200.00}
    result = builder.add(documents, add_attrs) do |doc|
      doc.field_by_name(:name).attrs[:boost] = 10
      doc.fields.size.should == 4
      doc.fields_by_name(:cat).size.should == 2
    end
    result.should match(%r(name="cat">cat 1</field>))
    result.should match(%r(name="cat">cat 2</field>))
    result.should match(%r(<add boost="200.0">))
    result.should match(%r(boost="10"))
    result.should match(%r(<field name="id">1</field>))
  end
  
  it 'should create a doc id delete' do
    builder.delete_by_id(10).should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?><delete><id>10</id></delete>"
  end
  
  it 'should create many doc id deletes' do
    builder.delete_by_id([1, 2, 3]).should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?><delete><id>1</id><id>2</id><id>3</id></delete>"
  end
  
  it 'should create a query delete' do
    builder.delete_by_query('status:"LOST"').should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?><delete><query>status:\"LOST\"</query></delete>"
  end
  
  it 'should create many query deletes' do
    builder.delete_by_query(['status:"LOST"', 'quantity:0']).should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?><delete><query>status:\"LOST\"</query><query>quantity:0</query></delete>"
  end
  
  # add a single hash ("doc")
  it 'should create an add from a hash' do
    data = {
      :id=>1,
      :name=>'matt'
    }
    result = builder.add(data)
    result.should match(/<field name="name">matt<\/field>/)
    result.should match(/<field name="id">1<\/field>/)
  end
  
  # add an array of hashes
  it 'should create many adds from an array of hashes' do
    data = [
      {
        :id=>1,
        :name=>'matt'
      },
      {
        :id=>2,
        :name=>'sam'
      }
    ]
    message = builder.add(data)
    expected = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><add><doc><field name=\"id\">1</field><field name=\"name\">matt</field></doc><doc><field name=\"id\">2</field><field name=\"name\">sam</field></doc></add>"
    message.should match(/<field name="name">matt<\/field>/)
    message.should match(/<field name="name">sam<\/field>/)
  end
  
  # multiValue field support test, thanks to Fouad Mardini!
  it 'should create multiple fields from array values' do
    data = {
      :id   => 1,
      :name => ['matt1', 'matt2']
    }
    result = builder.add(data)
    result.should match(/<field name="name">matt1<\/field>/)
    result.should match(/<field name="name">matt2<\/field>/)
  end
  
  it 'should create an add from a single Message::Document' do
    document = RSolr::Message::Document.new
    document.add_field('id', 1)
    document.add_field('name', 'matt', :boost => 2.0)
    result = builder.add(document)
    result.should match(/<field name="id">1<\/field>/)
    # this is a non-ordered hash work around,
    #   -- the order of the attributes in the resulting xml will be different depending on the ruby distribution/platform
    # begin
    #   result.should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?><add><doc><field name=\"id\">1</field><field boost=\"2.0\" name=\"name\">matt</field></doc></add>"
    # rescue
    #   result.should == "<add><doc><field name=\"id\">1</field><field name=\"name\" boost=\"2.0\">matt</field></doc></add>"
    # end
  end
  
  it 'should create adds from multiple Message::Documents' do
    documents = (1..2).map do |i|
      doc = RSolr::Message::Document.new
      doc.add_field('id', i)
      doc.add_field('name', "matt#{i}")
      doc
    end
    result = builder.add(documents)
    result.should match(/<field name="name">matt1<\/field>/)
    result.should match(/<field name="name">matt2<\/field>/)
  end
  
  # b = RSolr::Message::Builder.new
  # b.backend = :nokogiri
  # 
  # x = b.delete_by_id 1
  # puts x
  # 
  # r = b.add :id => 1 do |doc|
  #   doc.attrs[:boost] = 10
  # end
  # 
  # puts r
  
end