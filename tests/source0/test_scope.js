{
    const x = 123;
    {
        const x = 456;
        display(x);
    }
    display(x);
}
//123
//456