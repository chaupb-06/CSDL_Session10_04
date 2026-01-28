-- Bảng products
create table products (
    id serial primary key,
    name varchar(50),
    stock int
);

-- Bảng orders
create table orders (
    id serial primary key,
    product_id int references products(id),
    quantity int
);

-- Function trigger
create or replace function update_stock()
returns trigger as $$
begin
    if tg_op = 'INSERT' then
        update products
        set stock = stock - new.quantity
        where id = new.product_id;
        return new;
    elsif tg_op = 'UPDATE' then
        update products
        set stock = stock + old.quantity - new.quantity
        where id = new.product_id;
        return new;
    else
        update products
        set stock = stock + old.quantity
        where id = old.product_id;
        return old;
    end if;
end;
$$ language plpgsql;

-- Trigger
create trigger trg_update_stock
after insert or update or delete on orders
for each row
execute function update_stock();

-- Test
insert into products (name, stock) values ('Laptop', 50);

insert into orders (product_id, quantity) values (1, 5);
update orders set quantity = 8 where id = 1;
delete from orders where id = 1;

select * from products;
