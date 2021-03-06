require 'fileutils'

step "a file named :name with:" do |name, contents|
  parts = [@dir]
  dir = File.dirname(name)
  if !dir.empty?
    parts << dir
    FileUtils.mkdir_p(File.join(*parts))
  end
  parts << File.basename(name)
  IO.write(File.join(*parts), contents)
end

step "the following folders should not be empty:" do |table|
  table.raw.flatten.each do |relativePath|
    absPath = File.join(@dir, relativePath)
    expect(Dir.exists?(absPath)).to be(true), "expected #{relativePath} to exist, but it was not found"
    expect(Dir["#{absPath}/*"].empty?).to be(false), "expected #{relativePath} to non empty, but it was empty"
  end
end

step "the following folders should be empty:" do |table|
  table.raw.flatten.each do |relativePath|
    absPath = File.join(@dir, relativePath)
    expect(Dir["#{absPath}/*"].empty?).to be(true), "expected #{relativePath} to be empty, but it had content"
  end
end

step "the file :name should contain the following:" do |relativePath, table|
  absPath = File.join(@dir, relativePath)
  expect(File.file?(absPath)).to be(true), "Could not find file '#{relativePath}'"

  content = ""
  for line in IO.readlines(absPath)
    content += line
  end

  table.raw.flatten.each do |expected|
    expect(content.include? expected).to be(true), "expected '#{relativePath}' to contain '#{expected}', but it did not. found: \n#{content}"
  end
end

step "the file :name should not contain the following:" do |relativePath, table|
  absPath = File.join(@dir, relativePath)
  expect(File.file?(absPath)).to be(true), "Could not find file '#{relativePath}'"

  content = ""
  for line in IO.readlines(absPath)
    content += line
  end

  table.raw.flatten.each do |expected|
    expect(content.include? expected).to be(false), "expected '#{relativePath}' to not contain '#{expected}', but it did. found: \n#{content}"
  end
end

step "the file :name should be executable" do |relativePath|
  absPath = File.join(@dir, relativePath)
  expect(File.file?(absPath)).to be(true), "Could not find file '#{relativePath}'"

  expect(File.stat(absPath).executable?)
end

step "the file :name should exist" do |name|
  absPath = File.join(@dir, name)
  expect(File.file?(absPath)).to be(true), "#{name} should exist, but it did not"
end

step "the file :name should not exist" do |name|
  absPath = File.join(@dir, name)
  expect(File.file?(absPath)).to be(false), "#{name} should not exist, but it did"
end

step "the folder :folder should not exist" do |relativePath|
  absPath = File.join(@dir, relativePath)
  expect(Dir.exists?(absPath)).to be(false), "expected #{relativePath} not to exist, but it did"
end

step "the following folders should not exist" do |table|
  table.raw.flatten.each do |relativePath|
    send "the folder :folder should not exist", relativePath
  end
end
