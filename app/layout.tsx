import "./style.css";
export const metadata = {title:"PetBook Pro",description:"Every pet has a story"};
export default function RootLayout({children}:{children:React.ReactNode}){return <html lang="en"><body>{children}</body></html>}