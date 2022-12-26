const init = () => {
    document.getElementById('btnGetCustomer').onclick = (evt) => {
        fetch('/api/customers/1').
        then((data) => data.json()).
        then((customer) => {
            console.log(customer);
            document.getElementById('customer_name').innerText = customer.name;
            document.getElementById('customer_contact').innerText = `${customer.contactfirst} ${customer.contactlast}`;
            document.getElementById('customer_address').innerText = `${customer.addressline1}\n${customer.addressline2}`;
        });
    };
};
window.addEventListener('load', init);