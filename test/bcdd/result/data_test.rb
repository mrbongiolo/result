# frozen_string_literal: true

require 'test_helper'

class BCDD::Result
  class DataTest < Minitest::Test
    test '#name' do
      success = Success.new(type: :ok, value: 1)
      failure = Failure.new(type: :err, value: 0)

      assert_equal :success, success.data.name
      assert_equal :failure, failure.data.name
    end

    test '#type' do
      success = Success.new(type: :ok, value: 1)
      failure = Failure.new(type: :err, value: 0)

      assert_equal :ok, success.data.type
      assert_equal :err, failure.data.type
    end

    test '#value' do
      success = Success.new(type: :ok, value: 1)
      failure = Failure.new(type: :err, value: 0)

      assert_equal 1, success.data.value
      assert_equal 0, failure.data.value
    end

    test '#to_a' do
      success = Success.new(type: :ok, value: 1)
      failure = Failure.new(type: :err, value: 0)

      assert_equal([:success, :ok, 1], success.data.to_a)
      assert_equal([:failure, :err, 0], failure.data.to_a)
    end

    test '#to_ary' do
      success = Success.new(type: :ok, value: 1)
      failure = Failure.new(type: :err, value: 0)

      assert_equal([:success, :ok, 1], success.data.to_ary)
      assert_equal([:failure, :err, 0], failure.data.to_ary)
    end

    test '#to_h' do
      success = Success.new(type: :ok, value: 1)
      failure = Failure.new(type: :err, value: 0)

      assert_equal({ name: :success, type: :ok, value: 1 }, success.data.to_h)
      assert_equal({ name: :failure, type: :err, value: 0 }, failure.data.to_h)
    end

    test '#to_hash' do
      success = Success.new(type: :ok, value: 1)
      failure = Failure.new(type: :err, value: 0)

      assert_equal({ name: :success, type: :ok, value: 1 }, success.data.to_hash)
      assert_equal({ name: :failure, type: :err, value: 0 }, failure.data.to_hash)
    end

    test '#inspect' do
      success = Success.new(type: :ok, value: 1)
      failure = Failure.new(type: :err, value: 0)

      assert_equal(
        '#<BCDD::Result::Data name=:success type=:ok value=1>',
        success.data.inspect
      )

      assert_equal(
        '#<BCDD::Result::Data name=:failure type=:err value=0>',
        failure.data.inspect
      )
    end
  end
end
