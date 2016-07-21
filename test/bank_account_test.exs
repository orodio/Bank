defmodule BankAccountTest do
  use ExUnit.Case
  doctest BankAccount

  test "BankAccount starts off empty" do
    {:ok, pid} = BankAccount.start_link

    pid |> BankAccount.send_balance(self)

    assert_receive {:balance, 0}
  end

  test "deposit moneys" do
    {:ok, pid} = BankAccount.start_link

    pid |> BankAccount.deposit(50)
        |> BankAccount.send_balance(self)

    assert_receive {:balance, 50}
  end

  test "withdraw moneys" do
    {:ok, pid} = BankAccount.start_link

    pid |> BankAccount.deposit(100)
        |> BankAccount.withdraw(50)
        |> BankAccount.send_balance(self)

    assert_receive {:balance, 50}
  end

  test "cant deposit negative moneys" do
    {:ok, pid} = BankAccount.start_link

    pid |> BankAccount.deposit(50)
        |> BankAccount.deposit(-10)
        |> BankAccount.send_balance(self)

    assert_receive {:balance, 50}
  end

  test "cant withdraw negative moneys" do
    {:ok, pid} = BankAccount.start_link

    pid |> BankAccount.deposit(50)
        |> BankAccount.withdraw(-10)
        |> BankAccount.send_balance(self)

    assert_receive {:balance, 50}
  end

  test "not enough moneys to withdraw that amount" do
    {:ok, pid} = BankAccount.start_link


    pid |> BankAccount.deposit(50)
        |> BankAccount.withdraw(100)
        |> BankAccount.send_balance(self)

    assert_receive {:balance, 50}
  end

  test "#calc_balance(history)" do
    history = [
      deposit:  50,
      deposit:  50,
      withdraw: 50,
      withdraw: 60,
    ]

    assert -10 == BankAccount.calc_balance(history)
  end
end
