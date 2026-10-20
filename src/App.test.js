import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { MemoryRouter, useLocation, useNavigate } from 'react-router-dom';
import App from './App';
let mockSession=null;
let mockRole='admin';
const mockSignIn=jest.fn();
jest.mock('./config/supabaseClient',()=>({supabase:{
  auth:{getSession:async()=>({data:{session:mockSession}}),onAuthStateChange:()=>({data:{subscription:{unsubscribe:jest.fn()}}}),signInWithPassword:args=>mockSignIn(args),signOut:async()=>{}},
  from:()=>({select:()=>({eq:()=>({single:async()=>({data:{role:mockRole},error:null})})})})
}}));
jest.mock('./pages/DashboardPage',()=>()=> <h1>Authenticated dashboard</h1>);
function Location(){const location=useLocation();const navigate=useNavigate();return <><output data-testid="location">{location.pathname}</output><button onClick={()=>navigate(-1)}>Browser back</button></>;}
function renderApp(path='/'){return render(<MemoryRouter initialEntries={[path]}><App/><Location/></MemoryRouter>);}
beforeEach(()=>{mockSession=null;mockRole='admin';mockSignIn.mockReset();});

test('signed-out root displays the public landing and routes to sign-in and back',async()=>{
 renderApp();
 expect(await screen.findByRole('heading',{level:1})).toHaveTextContent('Behind every');
 fireEvent.click(screen.getAllByRole('link',{name:/Staff sign in/})[0]);
 expect(await screen.findByRole('button',{name:'Sign In to Console'})).toBeInTheDocument();
 expect(screen.getByTestId('location')).toHaveTextContent('/sign-in');
 expect(screen.getByRole('link',{name:'Back to website'})).toHaveAttribute('href','/');
 fireEvent.click(screen.getByRole('button',{name:'Browser back'}));
 expect(await screen.findByRole('heading',{level:1})).toHaveTextContent('Behind every');
});
test('direct sign-in loads its form',async()=>{
 renderApp('/sign-in');
 expect(await screen.findByRole('button',{name:'Sign In to Console'})).toBeInTheDocument();
});
test('unknown public routes return home',async()=>{
 renderApp('/unknown-page');
 expect(await screen.findByRole('heading',{level:1})).toHaveTextContent('Behind every');
 expect(screen.getByTestId('location')).toHaveTextContent('/');
});
test('authorized sessions redirect sign-in to the existing dashboard',async()=>{
 mockSession={user:{id:'admin-a'}};renderApp('/sign-in');
 expect(await screen.findByRole('heading',{name:'Authenticated dashboard'})).toBeInTheDocument();
 await waitFor(()=>expect(screen.getByTestId('location').textContent).toBe('/'));
});
test('adopter sessions cannot access the dashboard',async()=>{
 mockSession={user:{id:'adopter-a'}};mockRole='adopter';renderApp('/');
 expect(await screen.findByRole('heading',{name:'Access denied'})).toBeInTheDocument();
 expect(screen.queryByRole('heading',{name:'Authenticated dashboard'})).not.toBeInTheDocument();
});
test('successful sign-in resolves staff access before displaying the dashboard',async()=>{
 mockSignIn.mockResolvedValue({data:{user:{id:'staff-a'}},error:null});mockRole='shelter_staff';renderApp('/sign-in');
 await screen.findByRole('button',{name:'Sign In to Console'});
 fireEvent.change(screen.getByLabelText('Email address'),{target:{value:'staff@example.test'}});
 fireEvent.change(screen.getByLabelText('Password',{exact:true}),{target:{value:'test-password'}});
 fireEvent.click(screen.getByRole('button',{name:'Sign In to Console'}));
 expect(await screen.findByRole('heading',{name:'Authenticated dashboard'})).toBeInTheDocument();
 expect(mockSignIn).toHaveBeenCalledWith({email:'staff@example.test',password:'test-password'});
});
