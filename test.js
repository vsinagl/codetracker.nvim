
function main()
{
	const fuction_variable = function hello_world(x)
	{
		console.log("hello world!");
	}

	function do_twice(func)
	{
		func();
		func();
	}

	do_twice(fuction_variable);
}

main();
