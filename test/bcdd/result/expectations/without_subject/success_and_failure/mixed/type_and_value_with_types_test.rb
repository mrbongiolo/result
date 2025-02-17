# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::ExpectationsWithoutSubjectSuccessAndFailureTypeAndValueWithTypesTest < Minitest::Test
  class Divide
    Expected = BCDD::Result::Expectations.new(
      success: {
        numbers: Array,
        division_completed: Numeric
      },
      failure: %i[invalid_arg division_by_zero]
    )

    def call(arg1, arg2)
      validate_numbers(arg1, arg2)
        .and_then { |numbers| validate_non_zero(numbers) }
        .and_then { |numbers| divide(numbers) }
    end

    private

    def validate_numbers(arg1, arg2)
      arg1.is_a?(::Numeric) or return Expected::Failure(:invalid_arg, 'arg1 must be numeric')
      arg2.is_a?(::Numeric) or return Expected::Failure(:invalid_arg, 'arg2 must be numeric')

      Expected::Success(:numbers, [arg1, arg2])
    end

    def validate_non_zero(numbers)
      return Expected::Success(:numbers, numbers) unless numbers.last.zero?

      Expected::Failure(:division_by_zero, 'arg2 must not be zero')
    end

    def divide((number1, number2))
      Expected::Success(:division_completed, number1 / number2)
    end
  end

  test 'valid execution' do
    result = Divide.new.call(10, 2)

    assert result.success?(:division_completed)

    assert_predicate result, :success?

    # --

    result = Divide.new.call(10, 0)

    assert result.failure?(:division_by_zero)

    assert_predicate result, :failure?
  end

  test 'valid hooks' do
    increment = 0

    result = Divide.new.call(10, 5)

    result
      .on_failure { increment += 1 }
      .on_success { increment += 1 }
      .on_success(:division_completed) { increment += 1 }

    assert_equal 2, increment

    # ---

    decrement = 2

    result = Divide.new.call(10, 0)

    result
      .on_success { decrement -= 1 }
      .on_failure { decrement -= 1 }
      .on_failure(:division_by_zero) { decrement -= 1 }

    assert_equal 0, decrement
  end

  test 'valid handlers' do
    increment = 0

    Divide.new.call(10, 5).handle do |on|
      on.failure { increment += 1 }
      on.success { increment += 1 }
      on.success(:numbers, :division_completed) { increment += 1 }
    end

    Divide.new.call(10, 5).handle do |on|
      on.failure { increment += 1 }
      on.success(:numbers, :division_completed) { increment += 1 }
      on.success { increment += 1 }
    end

    assert_equal 2, increment

    # ---

    decrement = 2

    Divide.new.call(10, '2').handle do |on|
      on.success { decrement -= 1 }
      on.failure { decrement -= 1 }
      on.failure(:invalid_arg, :division_by_zero) { decrement -= 1 }
    end

    Divide.new.call(10, '0').handle do |on|
      on.success { decrement -= 1 }
      on.failure(:invalid_arg) { decrement -= 1 }
      on.failure { decrement -= 1 }
    end

    assert_equal 0, decrement
  end

  test 'invalid result type' do
    err1 = assert_raises(BCDD::Result::Expectations::Error::UnexpectedType) do
      Divide.new.call(10, 2).success?(:invalid_arg)
    end

    assert_equal(
      'type :invalid_arg is not allowed. Allowed types: :numbers, :division_completed',
      err1.message
    )

    # ---

    err2 = assert_raises(BCDD::Result::Expectations::Error::UnexpectedType) do
      Divide.new.call(10, '2').failure?(:numbers)
    end

    assert_equal(
      'type :numbers is not allowed. Allowed types: :invalid_arg, :division_by_zero',
      err2.message
    )
  end

  test 'invalid hooks' do
    result = Divide.new.call(6, 2)

    err1 = assert_raises(BCDD::Result::Expectations::Error::UnexpectedType) do
      result.on_success(:ok) { :this_type_is_not_defined_in_the_expectations }
    end

    err2 = assert_raises(BCDD::Result::Expectations::Error::UnexpectedType) do
      result.on_failure(:err) { :this_type_is_not_defined_in_the_expectations }
    end

    err3 = assert_raises(BCDD::Result::Expectations::Error::UnexpectedType) do
      result.on(:bar) { :this_type_is_not_defined_in_the_expectations }
    end

    assert_equal(
      'type :ok is not allowed. Allowed types: :numbers, :division_completed',
      err1.message
    )

    assert_equal(
      'type :err is not allowed. Allowed types: :invalid_arg, :division_by_zero',
      err2.message
    )

    assert_equal(
      'type :bar is not allowed. Allowed types: :numbers, :division_completed, :invalid_arg, :division_by_zero',
      err3.message
    )
  end

  test 'invalid handlers' do
    result = Divide.new.call(6, 2)

    err1 = assert_raises(BCDD::Result::Expectations::Error::UnexpectedType) do
      result.handle do |on|
        on.success(:ok) { :this_type_is_not_defined_in_the_expectations }
      end
    end

    err2 = assert_raises(BCDD::Result::Expectations::Error::UnexpectedType) do
      result.handle do |on|
        on.failure(:err) { :this_type_is_not_defined_in_the_expectations }
      end
    end

    err3 = assert_raises(BCDD::Result::Expectations::Error::UnexpectedType) do
      result.handle do |on|
        on.type(:bar) { :this_type_is_not_defined_in_the_expectations }
      end
    end

    assert_equal(
      'type :ok is not allowed. Allowed types: :numbers, :division_completed',
      err1.message
    )

    assert_equal(
      'type :err is not allowed. Allowed types: :invalid_arg, :division_by_zero',
      err2.message
    )

    assert_equal(
      'type :bar is not allowed. Allowed types: :numbers, :division_completed, :invalid_arg, :division_by_zero',
      err3.message
    )
  end

  test 'does not handle all cases' do
    err1 = assert_raises(BCDD::Result::Error::UnhandledTypes) do
      Divide.new.call(6, 2).handle do |on|
        on.success(:numbers) { :did_not_handle_all_expected_types }
      end
    end

    err2 = assert_raises(BCDD::Result::Error::UnhandledTypes) do
      Divide.new.call(6, '2').handle do |on|
        on.success { :did_not_handle_all_expected_types }
      end
    end

    err3 = assert_raises(BCDD::Result::Error::UnhandledTypes) do
      Divide.new.call(8, '2').handle do |on|
        on.failure { :did_not_handle_all_expected_types }
      end
    end

    err4 = assert_raises(BCDD::Result::Error::UnhandledTypes) do
      Divide.new.call(6, 2).handle do |on|
        on.failure(:division_by_zero) { :did_not_handle_all_expected_types }
      end
    end

    err5 = assert_raises(BCDD::Result::Error::UnhandledTypes) do
      Divide.new.call(6, 2).handle do |on|
        on.type(:division_completed) { :did_not_handle_all_expected_types }
      end
    end

    err6 = assert_raises(BCDD::Result::Error::UnhandledTypes) do
      Divide.new.call(6, 2).handle do |on|
        on.type(:division_by_zero) { :did_not_handle_all_expected_types }
      end
    end

    assert_equal(
      'You must handle all cases. These were not handled: :division_completed, :invalid_arg, :division_by_zero',
      err1.message
    )

    assert_equal(
      'You must handle all cases. These were not handled: :invalid_arg, :division_by_zero',
      err2.message
    )

    assert_equal(
      'You must handle all cases. These were not handled: :numbers, :division_completed',
      err3.message
    )

    assert_equal(
      'You must handle all cases. These were not handled: :numbers, :division_completed, :invalid_arg',
      err4.message
    )

    assert_equal(
      'You must handle all cases. These were not handled: :numbers, :invalid_arg, :division_by_zero',
      err5.message
    )

    assert_equal(
      'You must handle all cases. These were not handled: :numbers, :division_completed, :invalid_arg',
      err6.message
    )
  end
end
