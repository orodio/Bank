defmodule BankAccount do
  use GenServer

  @vsn 3



  ### External Api

  def start_link(),      do: start_link({0, []})
  def start_link(state), do: GenServer.start_link(BankAccount, state)

  @doc """
    # send_balance :: (Pid a, Pid b) => a -> b -> a

    Send the current balance of BankAccount "a" to actor "b"
  """
  def send_balance(account, pid) do
    GenServer.cast(account, {:send_balance, pid})
    account
  end

  def deposit(account, amount) do
    GenServer.cast(account, {:deposit, amount})
    account
  end

  def withdraw(account, amount) do
    GenServer.cast(account, {:withdraw, amount})
    account
  end



  ### Private Api

  @doc """
    # handle_cast

    iex> BankAccount.handle_cast({:withdraw, 5}, {10, []})
    {:noreply, {5, [withdraw: 5]}}

    iex> BankAccount.handle_cast({:withdraw, -5}, {10, []})
    {:noreply, {10, []}}

    iex> BankAccount.handle_cast({:withraw, 5}, {4, []})
    {:noreply, {4, []}}

    iex> BankAccount.handle_cast({:deposit, 5}, {0, []})
    {:noreply, {5, [deposit: 5]}}

    iex> BankAccount.handle_cast({:deposit, -5}, {0, []})
    {:noreply, {0, []}}
  """
  def handle_cast({:send_balance, pid}, state = {balance, _history}) do
    Process.send(pid, {:balance, balance}, [])
    {:noreply, state}
  end

  def handle_cast({:withdraw, amount}, state = {balance, _history}) when amount > balance do
    {:noreply, state}
  end

  def handle_cast(event = {:withdraw, amount}, {balance, history}) when amount >= 0 do
    {:noreply, {balance - amount, [event | history]}}
  end

  def handle_cast(event = {:deposit, amount}, {balance, history}) when amount >= 0 do
    {:noreply, {balance + amount, [event | history]}}
  end

  def handle_cast(_event, history) do
    {:noreply, history}
  end


  @doc """
    # code_change

    vsn | state              | example
    ----+--------------------+--------------------------------
    1   | balance            | 5
    2   | history            | [deposit: 10, withdraw: 5]
    3   | {balance, history} | {5, [deposit: 10, withdraw: 5]}

    ## 1 -> 3

    iex> BankAccount.code_change(1, 5, [])
    {:ok, {5,[ deposit: 5 ]}}

    iex> BankAccount.code_change(1, -5, [])
    {:ok, {-5, [deposit: -5]}}

    ## 2 -> 3

    iex> BankAccount.code_change(2, [ deposit: 5 ], [])
    {:ok, {5, [deposit: 5]}}

    iex> BankAccount.code_change(2, [ deposit: -5 ], [])
    {:ok, {-5, [deposit: -5]}}

    iex> BankAccount.code_change(2, [deposit: 10, withdraw: 5], [])
    {:ok, {5, [deposit: 10, withdraw: 5]}}

  """
  # Code Change
  def code_change(1, balance, _extra) do
    {:ok, {balance, [ deposit: balance ]}}
  end

  def code_change(2, history, _extra) do
    {:ok, {calc_balance(history), history}}
  end



  ### Helpers
  @doc """
    # calc_balance

    iex> BankAccount.calc_balance([])
    0

    iex> BankAccount.calc_balance([deposit: 5])
    5

    iex> BankAccount.calc_balance([deposit: 10, withdraw: 5])
    5

    iex> BankAccount.calc_balance([withdraw: 5])
    -5

    iex> BankAccount.calc_balance([deposit: 5, withdraw: 10])
    -5
  """
  def calc_balance(history), do: Enum.reduce(history, 0, &balance_reducer/2)

  def balance_reducer({:deposit,  value}, acc), do: acc + value
  def balance_reducer({:withdraw, value}, acc), do: acc - value
  def balance_reducer(_event, acc),             do: acc
end
