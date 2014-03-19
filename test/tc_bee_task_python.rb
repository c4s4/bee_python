#!/usr/bin/env ruby

require 'test/unit'
$:.unshift(File.join(File.expand_path(File.dirname(__FILE__))))
require 'bee_context'
require 'test_build'
require 'test_build_listener'
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'bee_task_python'

# Test case for bee task.
class TestBeeTaskPython < Test::Unit::TestCase

  # Create a context object and load tasks in it.
  def setup
    super
    @context = Bee::Context.new()
    @listener = TestBuildListener.new
    @build = TestBuild.new(@context, @listener)
    @package = Bee::Task::Python.new(@build)
  end

  def test_compile
    # TODO: write unit test
  end

end
